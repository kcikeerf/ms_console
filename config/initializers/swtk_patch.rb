#swtk user patch
require 'openssl'

class String
  $pass_phrase = "7cdcde8c-fe3b-11e6-afd0-00163e321126"
  $salt = "tksecret"

  def encrypt(pass_phrase=$pass_phrase,salt=$salt)
    encrypter = OpenSSL::Cipher.new 'AES-128-CFB'
    encrypter.encrypt
    encrypter.pkcs5_keyivgen pass_phrase, salt
    encrypted = encrypter.update self
    encrypted << encrypter.final
    Base64.encode64(encrypted).encode('utf-8') 
  end

  def decrypt(pass_phrase=$pass_phrase,salt=$salt)
    decrypter = OpenSSL::Cipher.new 'AES-128-CFB'
    decrypter.decrypt
    decrypter.pkcs5_keyivgen pass_phrase, salt
    target = Base64.decode64(self.encode('ascii-8bit') )
    plain = decrypter.update target
    plain << decrypter.final
  end
end

module TkEncryption
  module_function
  def codes_str_decryption code_file, secret_code=0
    begin
      encrypted_core_str = File.open(code_file, 'rb').read
      secrect_codes = nil
      case secret_code
      when 'x'
        secret_file = Rails.root + "config/x_secret.txt"
      else
        secret_file = Rails.root + "config/x_secret.txt"
      end
      if File.exists?(secret_file)
        secrect_codes = File.open(secret_file, 'rb').read
        secrect_codes.strip!
        secrect_codes.chomp!
      end
      return (secrect_codes.blank?? encrypted_core_str.decrypt : encrypted_core_str.decrypt(secrect_codes))
    rescue Exception => ex
      #
    end
  end
end

module Doorkeeper
  class AccessGrant
    belongs_to :user, foreign_key: "resource_owner_id", class_name: "User"
  end

  class AccessToken
    belongs_to :user, foreign_key: "resource_owner_id", class_name: "User"
  end

  class Application
    belongs_to :user, foreign_key: "resource_owner_id", class_name: "User"
  end
end

module Mongodb
    klass_version_1_0_arr = [
      "ReportEachLevelPupilNumberResult",
      "ReportFourSectionPupilNumberResult",
      "ReportStandDevDiffResult",
      "ReportTotalAvgResult",
      "ReportQuizCommentsResult",
      "MobileReportTotalAvgResult",
      "MobileReportBasedOnTotalAvgResult",
    ]
    
    #version1.1
    group_types = Common::Report::Group::ListArr
    base_result_klass_arr = []
    base_result_klass_arr += group_types.map{|t|
      collect_type = t.capitalize 
      [
        "Report"+ collect_type + "BaseResult",
        "Report"+ collect_type + "Lv1CkpResult",
        "Report"+ collect_type + "Lv2CkpResult",
        "Report"+ collect_type + "LvEndCkpResult",
        "Report"+ collect_type + "OrderResult",
        "Report"+ collect_type + "OrderLv1CkpResult",
        "Report"+ collect_type + "OrderLv2CkpResult",
        "Report"+ collect_type + "OrderLvEndCkpResult",
        "Report"+ collect_type + "BaseOutlineResult",
        "Report"+ collect_type + "Lv1OutlineResult",
        "Report"+ collect_type + "Lv2OutlineResult",
        "Report"+ collect_type + "LvEndOutlineResult"
      ]
    }

    # 用于在线测试
    pupil_stat_klass_arr = []
    pupil_stat_klass_arr += group_types[1..-1].map{|t|
      collect_type = t.capitalize 
      [
        "Report" + collect_type + "BeforeBasePupilStatResult",
        "Report" + collect_type + "BeforeLv1CkpPupilStatResult",
        "Report" + collect_type + "BeforeLv2CkpPupilStatResult",
        "Report" + collect_type + "BeforeLvEndCkpPupilStatResult",
        "Report" + collect_type + "MidmrBasePupilStatResult",
        "Report" + collect_type + "MidmrLv1CkpPupilStatResult",
        "Report" + collect_type + "MidmrLv2CkpPupilStatResult",
        "Report" + collect_type + "MidmrLvEndCkpPupilStatResult",
        "Report" + collect_type + "BasePupilStatResult",
        "Report" + collect_type + "Lv1CkpPupilStatResult",
        "Report" + collect_type + "Lv2CkpPupilStatResult",
        "Report" + collect_type + "LvEndCkpPupilStatResult"
      ]
    }

    online_test_types = Common::OnrineTest::Group::List

    online_test_klass_arr = online_test_types.map{|t|
      collect_type = t.capitalize 
      [
        "OnlineTestReport" + collect_type + "BaseResult",
        "OnlineTestReport" + collect_type + "Lv1CkpResult",
        "OnlineTestReport" + collect_type + "Lv2CkpResult",
        "OnlineTestReport" + collect_type + "LvEndCkpResult",
        "OnlineTestReport" + collect_type + "OrderResult",
        "OnlineTestReport" + collect_type + "OrderLv1CkpResult",
        "OnlineTestReport" + collect_type + "OrderLv2CkpResult",
        "OnlineTestReport" + collect_type + "OrderLvEndCkpResult"
      ]
    }

    online_test_pupil_stat_klass_arr = [
      "OnlineTestReportTotalBeforeBasePupilStatResult",
      "OnlineTestReportTotalBeforeLv1CkpPupilStatResult",
      "OnlineTestReportTotalBeforeLv2CkpPupilStatResult",
      "OnlineTestReportTotalBeforeLvEndCkpPupilStatResult"
    ]

    #综合在线测试
    zh_online_test_klass_arr = (Common::Report2::Group::List1Arr + Common::Report2::Group::List2Arr).flatten.uniq.map{|t|
      collect_type = t.capitalize 
      [
        "Report"+ collect_type + "Lv1CkpOverallResult",

      ]
    }

    klass_arr = [
      klass_version_1_0_arr,
      base_result_klass_arr, 
      pupil_stat_klass_arr,
      online_test_klass_arr,
      online_test_pupil_stat_klass_arr,
      zh_online_test_klass_arr
      ].flatten
    
    klass_arr.each{|klass|
      self.const_set(klass, Class.new)
      ("Mongodb::" + klass).constantize.class_eval do
        include Mongoid::Document
        include Mongoid::Attributes::Dynamic

        index({_id: 1}, {background: true})
      end
    }


    others = {
      "TestReportUrl" => %Q{
        include Mongoid::Document
        include Mongoid::Attributes::Dynamic

        index({_id: 1}, {background: true})
        index({test_id: 1}, {background: true})
        index({report_url: 1}, {background: true})
      }
    }
    others.each{|klass, core_str|
      self.const_set(klass, Class.new)
      ("Mongodb::" + klass).constantize.class_eval do
        eval(core_str)
      end
    }
end
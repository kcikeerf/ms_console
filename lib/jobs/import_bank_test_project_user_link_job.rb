class ImportBankProjectUserLinkJob < TkBaseJob
  attr_accessor :bank_test, :target_paper


  def initialize args
    super args
  end

  def phase1 bank_test_id
    bank_test = Mongodb::BankTest.where(_id: bank_test_id).first
    target_paper = bank_test.bank_paper_pap
    if target_paper.orig_file_id
      fu = FileUpload.where(id: target_paper.orig_file_id).first
    else
      fu = FileUpload.new
    end
    fu.user_base = params[:file_name]
    fu.save!
    target_paper.orig_file_id = fu.id
    target_paper.save!
    paper_xlsx = Roo::Excelx.new(fu.user_base.current_path)
    tenant_uids.each do |t_uid|
      user_base_excel = Axlsx::Package.new
      user_base_sheet = user_base_excel.workbook.add_worksheet(:name => "user_base")
      paper_xlsx.sheet(0).each do |row|
        next if row[1] != t_uid
        user_base_sheet.add_row(row, :types => [:string,:string,:string,:string,:string,:string,:string,:string,:string,:string,:string,:string,:string])
      end
      file_path = Rails.root.to_s + "/tmp/#{bank_test._id.to_s}.xlsx"
      user_base_excel.serialize(file_path)
      if bank_test.score_uploads.where(tenant_uid: t_uid).size > 0
        su = bank_test.score_uploads.where(tenant_uid: t_uid).first
      else
        su = ScoreUpload.new(tenant_uid: t_uid, test_id: bank_test._id.to_s)
      end
      su.user_base = Pathname.new(file_path).open
      su.save!
      File.delete(file_path)
      if bank_test_tenant_links.where(tenant_uid: t_uid).first.blank?
        Mongodb::BankTestTenantLink.new(bank_test_id: bank_test._id.to_s, tenant_uid: t_uid).save!
      end
      target_tenant = Tenant.where(uid: t_uid).first
      tenant_area = target_tenant.area
      if bank_test_area_links.where(area_uid: tenant_area.uid).first.blank?
        Mongodb::BankTestAreaLink.new(bank_test_id: bank_test._id.to_s, area_uid: tenant_area.uid).save!
      end
    end
    bank_test.score_uploads.each do |socre_upload|
      bank_link_user socre_upload
    end
  end

  def bank_link_user socre_upload
    target_tenant = Tenant.where(uid: socre_upload.tenant_uid).first
    bank_test = Mongodb::BankTest.where(_id: test_id).first
    target_area = target_tenant.area
    teacher_username_in_sheet = []
    pupil_username_in_sheet = []
    location_list = {}
    user_info_xlsx = Roo::Excelx.new(socre_upload.user_base.current_path)
    out_excel = Axlsx::Package.new
    wb = out_excel.workbook

    head_teacher_sheet = wb.add_worksheet(:name => Common::Locale::i18n('scores.excel.head_teacher_password_title'))
    teacher_sheet = wb.add_worksheet(:name => Common::Locale::i18n('scores.excel.teacher_password_title'))
    pupil_sheet = wb.add_worksheet(:name => Common::Locale::i18n('scores.excel.pupil_password_title'))
    new_user_sheet = wb.add_worksheet(:name => Common::Locale::i18n('scores.excel.new_user_title'))

    head_teacher_sheet.add_row Common::Uzer::UserAccountTitle[:head_teacher]
    teacher_sheet.add_row Common::Uzer::UserAccountTitle[:teacher]
    pupil_sheet.add_row Common::Uzer::UserAccountTitle[:pupil]
    new_user_sheet.add_row Common::Uzer::UserAccountTitle[:new_user]

    cols = {
      :tenant_name => 0,
      :tenant_uid => 1,
      :grade => 2,
      :grade_code => 3,
      :classroom =>4,
      :classroom_code => 5,
      :head_teacher_name => 6,
      :head_teacher_number => 7,
      :subject_teacher_name => 8,
      :subject_teacher_number => 9,
      :subject_teacher_subject => 10,
      :pupil_name => 11,
      :pupil_number => 12,
      :pupil_gender => 13
    }
    begin   
      if user_info_xlsx.sheet(0).last_row.present? 
        user_info_xlsx.sheet(0).each{|row|
          next if target_tenant.blank?

          grade_pinyin = Common::Locale.hanzi2pinyin(row[cols[:grade]].to_s.strip)
          klass_pinyin = Common::Locale.hanzi2pinyin(row[cols[:classroom]].to_s.strip)
          klass_value = Common::Klass::List.keys.include?(klass_pinyin.to_sym) ? klass_pinyin : row[cols[:classroom]].to_s.strip
          target_tenant_uid = target_tenant.try(:uid)

          cells = {
            :grade => grade_pinyin,
            :xue_duan => Common::Grade.judge_xue_duan(grade_pinyin),
            :classroom => klass_value,
            :head_teacher => row[cols[:head_teacher_name]].to_s.strip,
            :head_teacher_number => row[cols[:head_teacher_number]].to_s.strip,
            :teacher => row[cols[:subject_teacher_name]].to_s.strip,
            :teacher_number => row[cols[:subject_teacher_number]].to_s.strip,
            :pupil_name => row[cols[:pupil_name]].to_s.strip,
            :stu_number => row[cols[:pupil_number]].to_s.strip,
            :sex => row[cols[:pupil_gender]].to_s.strip
          }
          loc_h = { :tenant_uid => target_tenant_uid }
          loc_h.merge!({
            :area_uid => target_area.uid,
            :area_rid => target_area.rid
          }) if target_area

          loc_h[:grade] = cells[:grade]
          loc_h[:classroom] = cells[:classroom]
          loc_key = target_tenant_uid + cells[:grade] + cells[:classroom]
          if location_list.keys.include?(loc_key)
            loc = location_list[loc_key]
          else
            loc = Location.new(loc_h)
            loc.save!
            bank_test_location_link = Mongodb::BankTestLocationLink.new(bank_test_id: bank_test._id.to_s, loc_uid: loc.uid).save!
            location_list[loc_key] = loc
          end
          user_row_arr = []
          # 
          # create teacher user 
          #
          head_tea_h = {
            :loc_uid => loc.uid,
            :tenant_uid => target_tenant_uid,
            :name => cells[:head_teacher],
            :classroom => cells[:classroom],
            # :subject => @target_paper.subject,
            :head_teacher => true,
            :user_name =>Common::Uzer.format_user_name([
              target_tenant.number,
              #Common::Subject::Abbrev[@target_paper.subject.to_sym],
              cells[:head_teacher_number],
              Common::Locale.hanzi2abbrev(cells[:head_teacher])
            ])
          }
          user_row_arr = Common::Uzer.format_user_password_row(Common::Role::Teacher, head_tea_h)
          unless teacher_username_in_sheet.include?(user_row_arr[0])
            head_teacher_sheet.add_row(user_row_arr, :types => [:string,:string,:string,:string,:string,:string,:string]) 
            teacher_username_in_sheet << user_row_arr[0]
            Common::Uzer.link_user_and_bank_test(user_row_arr[0], bank_test._id.to_s)
            if !user_row_arr[-1] 
              user = User.find_by(name: user_row_arr[0])
              if user.present?
                new_user_sheet.add_row([user.id, bank_test._id.to_s, user_row_arr[0], user_row_arr[1]], :types => [:string,:string,:string,:string,:string,:string,:string,:string])
              end
            end          
          end
          #
          # create pupil user
          #
          tea_h = {
            :loc_uid => loc.uid,
            :tenant_uid => target_tenant_uid,
            :name => cells[:teacher],
            :classroom => cells[:classroom],
            :subject => row[cols[:subject_teacher_subject]],
            :head_teacher => false,
            :user_name => Common::Uzer.format_user_name([
              target_tenant.number,
              #Common::Subject::Abbrev[@target_paper.subject.to_sym],
              cells[:teacher_number],
              Common::Locale.hanzi2abbrev(cells[:teacher])
            ])
          }
          user_row_arr = Common::Uzer.format_user_password_row(Common::Role::Teacher, tea_h)
          unless teacher_username_in_sheet.include?(user_row_arr[0])
            teacher_sheet.add_row(user_row_arr, :types => [:string,:string,:string,:string,:string,:string,:string]) 
            teacher_username_in_sheet << user_row_arr[0]
            Common::Uzer.link_user_and_bank_test(user_row_arr[0], bank_test._id.to_s)          
            if !user_row_arr[-1]
              user = User.where(name: user_row_arr[0]).first
              if user.present?
                new_user_sheet.add_row([user.id, bank_test._id.to_s, user_row_arr[0], user_row_arr[1]], :types => [:string,:string,:string,:string,:string,:string,:string,:string])
              end          
            end 
          end

          # #
          # # create pupil user
          # #
          pup_h = {
            :loc_uid => loc.uid,
            :tenant_uid => target_tenant_uid,
            :name => cells[:pupil_name],
            :stu_number => cells[:stu_number],
            :grade => cells[:grade],
            :classroom => cells[:classroom],
            :subject => row[cols[:subject_teacher_subject]],
            :sex => Common::Locale.hanzi2pinyin(cells[:sex]),
            :user_name => Common::Uzer.format_user_name([
              target_tenant.number,
              cells[:stu_number],
              Common::Locale.hanzi2abbrev(cells[:pupil_name])
            ])
          }
          p user_row_arr = Common::Uzer.format_user_password_row(Common::Role::Pupil, pup_h)
          unless pupil_username_in_sheet.include?(user_row_arr[0])
            pupil_sheet.add_row(user_row_arr, :types => [:string,:string,:string,:string,:string,:string,:string,:string]) 
            pupil_username_in_sheet << user_row_arr[0]
            Common::Uzer.link_user_and_bank_test(user_row_arr[0], bank_test._id.to_s)          
            if !user_row_arr[-1] 
              user = User.find_by(name: user_row_arr[0])
              if user.present?
                new_user_sheet.add_row([user.id, bank_test._id.to_s, user_row_arr[0], user_row_arr[1]], :types => [:string,:string,:string,:string,:string,:string,:string,:string])
              end
            end 
          end
        }
      end
    rescue Exception => e
      p e.message
      p e.backtrace
    ensure 
      file_path = Rails.root.to_s + "/tmp/#{bank_test._id.to_s}_bank_test_password.xlsx"
      out_excel.serialize(file_path)
      su.usr_pwd_file = Pathname.new(file_path).open
      su.save!
      File.delete(file_path)
    end
  end

  def phase1_rollback
    socre_uploads = self.bank_test.score_uploads
    score_uploads.each {|su|
      if su.usr_pwd_file
        user_info_xlsx = Roo::Excelx.new(su.usr_pwd_file.current_path)
        if user_info_xlsx.sheet(3).last_row.present? 
        user_info_xlsx.sheet(3).each_with_index do |row,index|
            next if index == 0
            user = User.where(id: row[0]).first
            #user.role_obj.destroy
            user.destroy if user
          end
          if bank_test.bank_test_user_links.present?
            bank_test.bank_test_user_links.destroy_all
          end
          if bank_test.locations.present?
            bank_test.locations.destroy_all
            bank_test.bank_test_location_links.destroy_all
          end
          if bank_test.bank_test_area_links.present?
            bank_test.bank_test_area_links.destroy
          end
          if bank_test.bank_test_tenant_links.present?
            bank_test.bank_test_tenant_links.destroy_all
          end
      end
    }
  end 
end
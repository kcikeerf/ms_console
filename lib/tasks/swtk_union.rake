# -*- coding: UTF-8 -*-

require 'ox'
require 'roo'
require 'axlsx'

namespace :swtk do
  namespace :union do
  	#namespace :v1_2 do

      desc "输出大榜信息"
      task :output_rank_list,[:union_test_id,:target_group] => :environment do |t, args|
        target_union_test_id = args[:union_test_id]
        target_group = args[:target_group]
        if target_union_test_id.blank?
          puts "Command format not correct."
          exit
        end

        begin
        target_union_test = Mongodb::UnionTest.where(id: target_union_test_id).first
        target_tests = target_union_test.bank_tests
        target_papers = target_tests.map{|item| item.bank_paper_pap }
        target_test_ids = target_tests.map{|item| item.id.to_s } # 此处的顺序，与学科试卷的数组顺序相同，如需特别指定，需要排序
        target_grade = Common::Grade::List[target_papers.first.grade.to_sym]

        title_row_items = [
          "Tenant",
          "Grade",
          "ClassRoom",
          "Name",
          "Student Number",
          "Rank",
          "Percentile",
          "Total Score",
          "IsAbsent"
        ] + target_papers.map{|pap| Common::Locale::i18n("dict." + pap.subject) }

        union_rank_paths = Dir[Common::Report::WareHouse::ReportLocation + "reports_warehouse/union/" +  target_union_test_id + "/**/*rank.json"]
        re_str = target_group ? ".*" + target_group + "/[0-9]{1,}/(knowledge|skill|ability)_rank.json$" : ".*/(knowledge|skill|ability)_rank.json$"
        re = Regexp.new(re_str)
        target_rank_paths = union_rank_paths.find_all{|item| item =~ re }
        p "!!!!#{target_rank_paths}"
        target_rank_paths.each{|rank_item|

          #写入excel
          out_excel = Axlsx::Package.new
          wb = out_excel.workbook
          wb.add_worksheet name: "rank list" do |sheet|
            
            sheet.add_row(title_row_items)

            fdata = File.open(rank_item, 'rb').read
            jdata = eval(fdata)
            jdata.each{|j_item|
              target_tenant = nil
              target_tenant_uid = j_item["_id"]["tenant_uid"]
              if target_tenant_uid.present?
                target_tenant_redis_key = Common::SwtkRedis::Prefix::Reports + "Tenant/" + target_tenant_uid
                if $cache_redis.exists(target_tenant_redis_key)
                  target_tenant = eval($cache_redis.get(target_tenant_redis_key))
                else
                  target_tenant = Tenant.where(uid: target_tenant_uid).first
                  target_tenant = target_tenant.attributes if target_tenant
                end
              end

              target_location = nil
              target_location_uid = j_item["_id"]["loc_uid"]
              if target_location_uid.present?
                target_location_redis_key = Common::SwtkRedis::Prefix::Reports + "Location/" + target_location_uid
                if $cache_redis.exists(target_location_redis_key)
                  target_location = eval($cache_redis.get(target_location_redis_key))
                else
                  target_location = Location.where(uid: target_location_uid).first
                  target_location = target_location.attributes if target_location
                end
              end            

              target_pupil = nil
              target_pupil_uid = j_item["_id"]["pup_uid"]
              if target_pupil_uid.present?
                target_pupil_redis_key = Common::SwtkRedis::Prefix::Reports + "Pupil/" + target_pupil_uid
                if $cache_redis.exists(target_pupil_redis_key)
                  target_pupil = eval($cache_redis.get(target_pupil_redis_key))
                else
                  target_pupil = Pupil.where(uid: j_item["_id"]["pup_uid"]).first
                  target_pupil = target_pupil.attributes if target_pupil
                end
              end
              next unless target_pupil

              tenant_name = target_tenant ? target_tenant["name_cn"] : ""
              class_room = target_location ? Common::Klass::List[target_location["classroom"].to_sym] : ""
              is_absent = target_test_ids.sort != j_item["value"]["union_tests_ids"].sort
              subjects_scores = j_item["value"]["union_tests_ids"].zip(j_item["value"]["union_tests_real_weights_scores"])
              subjects_scores.sort!{|a,b| a[0] <=> b[0]}

              # "Tenant",
              # "Grade",
              # "ClassRoom",
              # "Name",
              # "Student Number",
              # "Rank",
              # "Percentile",
              # "Total Score",
              # "IsAbsent"

              data_row = [
                tenant_name,
                target_grade,
                class_room,
                target_pupil["name"],
                target_pupil["stu_number"],
                j_item["value"]["rank"],
                j_item["value"]["percentile"],
                j_item["value"]["union_total_real_weights_score"],
                is_absent
              ] + subjects_scores.map{|score| score[1] }

              sheet.add_row(data_row)
            }

          end

          file_prefix = rank_item.split(".json")[0]
          file_prefix_arr = file_prefix.split("/")
          file_prefix_arr.delete(".")
          file_prefix_arr.delete("reports_warehouse")
          file_path = Rails.root.to_s + "/tmp/" + file_prefix_arr.join("_") + ".xlsx"
          out_excel.serialize(file_path)
          puts "Output: " + file_path 

        }
        rescue Exceptio => ex
          p ex.message
          p ex.backtrace
        end
      end

    #end
  end
end

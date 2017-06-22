# -*- coding: UTF-8 -*-

require 'ox'
require 'roo'
require 'axlsx'

namespace :swtk do
  namespace :report do
  	namespace :v1_2 do

      desc "输出区域报告用数据表"
      task :export_test_overall_report_data_table,[] => :environment do |t, args|
        ReportWarehousePath = "/reports_warehouse/tests/"
        _test_ids = args.extras
        _test_count = _test_ids.size
        _test_arr = _test_ids.map{|test_id|
          target_test = Mongodb::BankTest.find(test_id)
          target_paper = target_test.bank_paper_pap
          tenant_nav_file = Dir[ReportWarehousePath + test_id + '/**/project/' + test_id + "/nav.json"].first.to_s
          fdata = File.open(tenant_nav_file, 'rb').read
          nav_h =JSON.parse(fdata)
          fdata = File.open(ReportWarehousePath + test_id + "/ckps_qzps_mapping.json", 'rb').read
          ckps_json =JSON.parse(fdata)
          ckps_data = ckps_json.values[0]
          {
            :id => test_id,
            :pap_heading => target_paper.heading,
            :subject => Common::Subject::List[target_paper.subject.to_sym],
            :ckps => ckps_data,
            :tenants => nav_h.values[0]
          }
        }
        _data_types = [
          {
            :label => "平均得分率",
            :key => "weights_score_average_percent"
          },
          {
            :label => "中位数得分率",
            :key => "_median_percent"
          },
          {
            :label => "分化度",
            :key => "diff_degree"
          }
        ]

        #写入excel
        out_excel = Axlsx::Package.new
        wb = out_excel.workbook
        
        ####### 标题行，指标列, begin #######
        cell_style = {
          :knowledge => wb.styles.add_style(:bg_color => "FF00F7", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
          :skill => wb.styles.add_style(:bg_color => "FFCB1C", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
          :ability => wb.styles.add_style(:bg_color => "00BCFF", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
          :total => wb.styles.add_style(:bg_color => "5DC402", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
          :label => wb.styles.add_style(:bg_color => "CBCBCB", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 14, :alignment => { :horizontal=> :center }),
          :percentile => wb.styles.add_style(:bg_color => "E6FF00", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center })
        }

        _test_arr.each{|target_test|
          _data_types.each{|data_type|
            sheet_name = target_test[:id] + "_" + target_test[:subject] + "_" + data_type[:label]
            sheet_name = sheet_name[(sheet_name.size - 30)..(sheet_name.size - 1)]
            wb.add_worksheet name: sheet_name do |sheet|
              ####### 制表头, begin #######
              #标题行
              title_row2_info = [
                "类别",
                "名称",
                "班级数",
                "学生数"
              ]
              style_row2_info = title_row2_info.size.times.map{|t| cell_style[:label] }

              #标题行
              title_row2_info_length = title_row2_info.size - 1
              title_row1_info = [target_test[:pap_heading]] + title_row2_info_length.times.map{|t| ""}
              style_row1_info = title_row2_info.size.times.map{|t| cell_style[:label] }

              #标题1行
              title_row1_lv1 = []
              title_row1_total = ["总得分率","",""]           
              style_row1_lv1 = []
              style_row1_total = []
              
              #标题2行
              title_row2_lv1 = []
              title_row2_total = []
              style_row2_lv1 = []
              style_row2_total = []

              target_test[:ckps].each{|k0,v0| #三维
                dim_label = I18n.t("dict.#{k0}")
                dim_lv1_data = v0["lv_n"].map{|lv1| lv1.values[0]}.flatten
                title_row1_lv1.push(dim_label + "一级得分率")
                dim_lv1_data.each_with_index{|item, index| #一级指标
                  title_row1_lv1.push("") if index > 0
                  title_row2_lv1.push(item["checkpoint"])
                  style_row1_lv1 << cell_style[k0.to_sym]
                  style_row2_lv1 << cell_style[k0.to_sym]
                }

               
                title_row2_total << dim_label
                style_row1_total << cell_style[:total]
                style_row2_total << cell_style[:total]
              }
              # 表头第1行
              sheet.add_row(
                  title_row1_info + title_row1_lv1  + title_row1_total,
                  :style => style_row1_info + style_row1_lv1 + style_row1_total 
              )
              # 表头第2行
              sheet.add_row(
                  title_row2_info + title_row2_lv1 + title_row2_total,
                  :style => style_row2_info + style_row2_lv1 + style_row2_total
              )
              ####### 制表头, end #######

              ####### 输出数据, begin #######

              # 测试整体数据
              target_test_report_file = Dir[ReportWarehousePath + target_test[:id] + "/project/" + target_test[:id] + ".json"].first.to_s
              rpt_h = get_report_hash(target_test_report_file)

              data_row_info = [
                "区域整体",
                target_test[:pap_heading],
                "-",
                rpt_h["data"]["knowledge"]["base"]["pupil_number"]
              ]

              target_value_key = data_type[:key].include?("_median_percent") ? "project_median_percent" : data_type[:key]
              overall_data_row = get_report_data_row(rpt_h["data"], target_value_key)
              sheet.add_row data_row_info + overall_data_row

              # 各学校数据
              target_test[:tenants].each{|tnt|
                target_test_report_file = Dir[ReportWarehousePath + target_test[:id] + '/**/grade/' + tnt[1]["uid"] + ".json"].first.to_s
                rpt_h = get_report_hash(target_test_report_file)
                tenant_nav_file = Dir[ReportWarehousePath + target_test[:id] + '/**/grade/' + tnt[1]["uid"] + "/nav.json"].first.to_s
                nav_h = get_report_hash(tenant_nav_file)

                data_row_info = [
                  "学校",
                  tnt[1]["label"],
                  nav_h.values[0].size,
                  rpt_h["data"]["knowledge"]["base"]["pupil_number"]
                ]

                target_value_key = data_type[:key].include?("_median_percent") ? "grade_median_percent" : data_type[:key]
                overall_data_row = get_report_data_row(rpt_h["data"], target_value_key)
                sheet.add_row data_row_info + overall_data_row
              }
              ####### 输出数据， end ########
            end #测试总览
          }
        }

        file_path = Rails.root.to_s + "/tmp/" + Time.now.to_i.to_s + ".xlsx"
        out_excel.serialize(file_path)        
        puts "Output: " + file_path 
      end # export_test_area_report_tenants_basic, end

      # desc "输出测试大榜信息"
      # task :export_test_pupil_data_table,[] => :environment do |t, args|
      #   ReportWarehousePath = "/reports_warehouse/tests/"
      #   _test_ids = args.extras
      #   _test_count = _test_ids.size
      #   _test_arr = _test_ids.map{|test_id|
      #     target_test = Mongodb::BankTest.find(test_id)
      #     target_paper = target_test.bank_paper_pap
      #     target_pupil_urls = find_all_pupil_report_urls(Rails.root.to_s, ReportWarehousePath + test_id + "/",[])
      #     re = Regexp.new ".*pupil/(.*).json"
      #     target_pupil_uids = target_pupil_urls.map{|url| 
      #       r = re.match(url) 
      #       r.blank? ? nil : r[1].to_s
      #     }.compact

      #     {
      #       :id => test_id,
      #       :pap_heading => target_paper.heading,
      #       :subject => Common::Subject::List[target_paper.subject.to_sym],
      #       :pupil_report_urls => target_pupil_urls,
      #       :pupil_uids => target_pupil_uids
      #     }
      #   }
      #   _all_pupil_uids = eval(_test_arr.map{|item| "#{item[:pup_uids]}" }.join("&"))


      #   #写入excel
      #   out_excel = Axlsx::Package.new
      #   wb = out_excel.workbook
        
      #   ####### 标题行，指标列, begin #######
      #   cell_style = {
      #     :knowledge => wb.styles.add_style(:bg_color => "FF00F7", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
      #     :skill => wb.styles.add_style(:bg_color => "FFCB1C", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
      #     :ability => wb.styles.add_style(:bg_color => "00BCFF", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
      #     :total => wb.styles.add_style(:bg_color => "5DC402", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center }),
      #     :label => wb.styles.add_style(:bg_color => "CBCBCB", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 14, :alignment => { :horizontal=> :center }),
      #     :percentile => wb.styles.add_style(:bg_color => "E6FF00", :border => { :style => :thin, :color => "00" },:fg_color => "000000", :sz => 12, :alignment => { :horizontal=> :center })
      #   }

      #       wb.add_worksheet name: "大榜" do |sheet|

      #         ####### 标题行，指标列, begin #######
      #         #标题行
      #         title_row2_info = [
      #           I18n.t("dict.province"),
      #           I18n.t("dict.city"),
      #           I18n.t("dict.district"),
      #           "Tenant",
      #           I18n.t("dict.grade"),
      #           I18n.t("dict.classroom"),
      #           I18n.t("dict.head_teacher"), 
      #           I18n.t("dict.subject_teacher"), 
      #           I18n.t("activerecord.attributes.user.name"),
      #           I18n.t("dict.pupil_number"), 
      #           I18n.t("dict.sex")#,
      #           # I18n.t("scores.grade_rank")
      #         ]

      #         #标题行
      #         title_row1_info = ["大榜"]
      #         title_row1_info += (title_row2_info.size-1).times.map{|t| ""}
      #         style_row1_info = title_row2_info.size.times.map{|t| cell_style[:label] }

      #         #标题1行
      #         title_row1_total = []
              
      #         style_row1_total = []
              
      #         #标题2行
      #         title_row2_total = []
      #         style_row2_total = []

      #         fdata = File.open(ReportWarehousePath + "/ckps_qzps_mapping.json", 'rb').read
      #         ckps_json =JSON.parse(fdata)

      #         ckps_data = ckps_json.values[0]
      #         title_row1_total = ["总得分率","",""]
      #         # title_row1_percentile = ["整体百分位等级","",""]
      #         ckps_data.each{|k0,v0| #三维
      #           dim_label = I18n.t("dict.#{k0}")
      #           dim_lv1_data = v0["lv_n"].map{|lv1| lv1.values[0]}.flatten
      #           title_row1_lv1.push(dim_label + "一级得分率")
      #           dim_lv1_data.each_with_index{|item, index| #一级指标
      #             title_row1_lv1.push("") if index > 0
      #             title_row2_lv1.push(item["checkpoint"])
      #             style_row1_lv1 << cell_style[k0.to_sym]
      #             style_row2_lv1 << cell_style[k0.to_sym]
      #           }

      #           dim_lv2_data = dim_lv1_data.map{|lv1| lv1["items"].map{|lv2| lv2.values[0]} }.flatten
      #           title_row1_lv2.push(dim_label + "二级得分率")
      #           dim_lv2_data.each_with_index{|item, index| #二级指标
      #             title_row1_lv2.push("") if index > 0
      #             title_row2_lv2.push(item["checkpoint"])
      #             style_row1_lv2 << cell_style[k0.to_sym]
      #             style_row2_lv2 << cell_style[k0.to_sym]
      #           }

                
      #           title_row2_total << dim_label
      #           style_row1_total << cell_style[:total]
      #           style_row2_total << cell_style[:total]

      #           # title_row2_percentile << dim_label
      #           # style_row1_percentile << cell_style[:percentile]
      #           # style_row2_percentile << cell_style[:percentile]

      #         }

      #         group_index = Common::Report::Group::ListArr.find_index(args[:top_group])
      #         Common::Report::Group::ListArr[1..group_index].each{|group|
      #           case group
      #           when "klass"
      #             title_row1_percentile += ["班级百分位等级","",""]
      #           when "grade"
      #             title_row1_percentile += ["年级百分位等级","",""]
      #           when "project"
      #             title_row1_percentile += ["联考百分位等级","",""]
      #           end
      #           Common::CheckpointCkp::TYPE.each{|dim|
      #             dim_label = I18n.t("dict.#{dim}")
      #             title_row2_percentile << dim_label
      #             style_row1_percentile << cell_style[:percentile]
      #             style_row2_percentile << cell_style[:percentile]
      #           }
      #         }

      #         sheet.add_row(
      #             title_row1_info + title_row1_lv1  + title_row1_total + title_row1_percentile  + title_row1_lv2,
      #             :style => style_row1_info + style_row1_lv1 + style_row1_total + style_row1_percentile  + style_row1_lv2 
      #         )

      #         sheet.add_row(
      #             title_row2_info + title_row2_lv1 + title_row2_total + title_row2_percentile   + title_row2_lv2,
      #             :style => style_row1_info + style_row2_lv1 + style_row2_total + style_row2_percentile + style_row2_lv2
      #         )
      #         ####### 标题行，指标列, begin #######

      #         ####### 学生数据行, begin #######
      #         #数据行


      #         urls = find_all_pupil_report_urls base_path,ReportWarehousePath,[]
      #         urls.each{|item|
      #           rpt_path = base_path + item
      #           fdata = File.open(rpt_path, 'rb').read
      #           rpt_json =JSON.parse(fdata)
      #           rpt_data = rpt_json["data"]

      #           path_arr = item.split(".json")[0].split("/")
      #           target_pupil = nil
      #           target_location = nil
      #           target_tenant = nil
      #           Common::Report::Group::ListArr[0..group_index].each{|group|
      #             group_pos = path_arr.find_index(group)
      #             group_uid = path_arr[group_pos + 1]
      #             case group
      #             when "pupil"
      #               target_pupil = Pupil.where(uid: group_uid).first
      #             when "klass"
      #               target_location = Location.where(uid: group_uid).first
      #             when "grade"
      #               target_tenant = Tenant.where(uid: group_uid).first
      #             else
      #               # do nothing
      #             end

      #           }

      #           if target_tenant.blank? ||  target_location.blank? ||  target_pupil.blank?
      #             puts "invalid path data"
      #             puts "path: #{item}"
      #             puts "tenant: #{target_tenant}"
      #             puts "location: #{target_location}"
      #             puts "pupil: #{target_pupil}"
      #             next
      #           end

      #           target_area = target_tenant.area
      #           data_row_info = [
      #             target_area.blank?? ["","",""] : target_area.pcd_h.values.map{|item| item[:name_cn]},
      #             target_tenant.name_cn,
      #             Common::Grade::List[target_location.grade.to_sym],
      #             Common::Klass::List[target_location.classroom.to_sym],
      #             target_location.head_teacher.blank?? "-" : target_location.head_teacher.name,
      #             target_location.subject_teacher(target_pap.subject).nil?? "-" : target_location.subject_teacher(target_pap.subject).name,
      #             target_pupil.name,
      #             target_pupil.stu_number,
      #              Common::Locale::i18n("dict.#{target_pupil.sex}")
      #           ].flatten

      #           data_row_lv1 = []
      #           data_row_total = []
      #           data_row_percentile = []
      #           data_row_lv2 = []

      #           rpt_data.each{|k0,v0| #三维
      #             rpt_lv1_data = v0["lv_n"].map{|lv1| lv1.values[0]}.flatten
      #             rpt_lv1_data.each_with_index{|item, index| #一级指标
      #               data_row_lv1.push(item["weights_score_average_percent"])
      #             }

      #             rpt_lv2_data = rpt_lv1_data.map{|lv1| lv1["items"].map{|lv2| lv2.values[0]} }.flatten
      #             rpt_lv2_data.each_with_index{|item, index| #二级指标
      #               data_row_lv2.push(item["weights_score_average_percent"])
      #             }

      #             data_row_total.push(v0["base"]["weights_score_average_percent"])
      #             percentile_keys = v0["base"].keys.find_all{|a| a.include?("percentile")}
      #             percentile_keys.size.times{|i| data_row_percentile.push([])} if data_row_percentile.blank?
      #             percentile_keys.each_with_index{|k, index|
      #               data_row_percentile[index].push(v0["base"][k])
      #             }
      #           }

      #           sheet.add_row data_row_info + data_row_lv1 + data_row_total + data_row_percentile.flatten + data_row_lv2   
      #         }

      #         ####### 学生数据行, begin #######
      #       end

      #   file_path = Rails.root.to_s + "/tmp/" + Time.now.to_i.to_s + ".xlsx"
      #   out_excel.serialize(file_path)        
      #   puts "Output: " + file_path 
      # end # export_test_area_report_tenants_basic, end

      # 获取报告数据HASH
      def get_report_hash file_path
        fdata = File.open(file_path, 'rb').read
        JSON.parse(fdata)        
      end

      # 获取报告数据行
      def get_report_data_row rpt_data, which_data
        data_row_lv1 = []
        data_row_total = []

        rpt_data.each{|k0,v0| #三维
          rpt_lv1_data = v0["lv_n"].map{|lv1| lv1.values[0]}.flatten
          rpt_lv1_data.each_with_index{|item, index| #一级指标
            data_row_lv1.push(item[which_data])
          }
          data_row_total.push(v0["base"][which_data])
        }
        return data_row_lv1 + data_row_total
      end

      # 查找所有学生
      def find_all_pupil_report_urls base_path, search_path, urls=[]
        fdata = File.open(search_path + "/nav.json", 'rb').read
        jdata = JSON.parse(fdata)
        jdata.values[0].each{|item|
          current_report_url = item[1]["report_url"]
          next_search_path = base_path + current_report_url.split(".json")[0]
          unless jdata.keys[0].include?("klass")
            urls = find_all_pupil_report_urls base_path, next_search_path, urls
          else
            urls.push(current_report_url)
          end
        }
        return urls
      end

    end
  end
end
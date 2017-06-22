# -*- coding: UTF-8 -*-

require 'ox'
require 'roo'
require 'axlsx'

namespace :swtk do
  namespace :report do
  	namespace :v1_2 do

      desc "export test overall report data table"
      task :export_test_overall_report_data_table,[] => :environment do |t, args|
        ReportWarehousePath = Rails.root.to_s + "/reports_warehouse/tests/"
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
            :key => "stand_dev"
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
                  target_test[:pap_heading],
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

      def get_report_hash file_path
        fdata = File.open(file_path, 'rb').read
        JSON.parse(fdata)        
      end

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
    end
  end
end
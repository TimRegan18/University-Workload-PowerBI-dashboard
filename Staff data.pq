let
    Source = SharePoint.Files("https://uonstaff.sharepoint.com/sites/HCISS", [ApiVersion = 15]),
    #"Filtered Rows1" = Table.SelectRows(Source, each ([Extension] = ".xlsx") and ([Name] = "WL-PowerBI Data.xlsx")),
    #"WL-PowerBI Data xlsx_https://uonstaff sharepoint com/sites/" = #"Filtered Rows1"{[Name="WL-PowerBI Data.xlsx",#"Folder Path"="https://uonstaff.sharepoint.com/sites/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"WL-PowerBI Data xlsx_https://uonstaff sharepoint com/sites/"),
    #"Course data_Sheet" = #"Imported Excel Workbook"{[Item="Staff data",Kind="Sheet"]}[Data],
    #"Promoted Headers1" = Table.PromoteHeaders(#"Course data_Sheet", [PromoteAllScalars=true]),
    #"Filtered Rows" = Table.SelectRows(#"Promoted Headers1", each ([Staff] <> null)),
    #"Changed Type1" = Table.TransformColumnTypes(#"Filtered Rows",{{"Staff", type text}, {"FTE", type number}, {"Target % Teaching Load", type number}, {"New Course %", type number}, {"Total Actual Allocation", type number}, {"Governance % Allocation", type number}, {"Approved Project Allocation", type text}, {"Project % Allocation", type number}, {"FTE reductions for SSP and/or external governance", type number}, {"Base Governance %", type number}, {"Total Governance %", type number}, {"Total Project %", type number}, {"Total Research %", type number}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type1", "Governance Project total", each [#"Governance % Allocation"]+[#"Project % Allocation"]),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Target % Teaching Load percentage", each [#"Target % Teaching Load"]/100),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "New Course Allocated to Staff percent", each [#"New Course % Allocated to Staff"]/100),
    #"Added Custom3" = Table.AddColumn(#"Added Custom2", "Governance Project total percentage", each [Governance Project total]/100),
    #"Added Custom4" = Table.AddColumn(#"Added Custom3", "Total Actual Allocation percentage", each [Total Actual Allocation]/100),
    #"Added Custom5" = Table.AddColumn(#"Added Custom4", "New Course Percent", each [#"New Course %"]/100),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom5",{{"Project % Allocation", type number}, {"Project % Allocation_1", type number}}),
    #"Added Custom6" = Table.AddColumn(#"Changed Type1", "Project percent", each [#"Project % Allocation"]/100),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom6",{"Governance % Allocation", "Project % Allocation", "Base Governance %", "Total Governance %", "Total Project %", "Total Actual Allocation", "Target % Teaching Load", "Total Research %", "New Course %"}),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Removed Columns", "Governance Role", Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, false), {"Governance Role.1", "Governance Role.2"}),
    #"Split Column by Delimiter1" = Table.SplitColumn(#"Split Column by Delimiter", "Governance Role.2", Splitter.SplitTextByDelimiter("%", QuoteStyle.Csv), {"Governance Role.2.1", "Governance Role.2.2"}),
    #"Split Column by Delimiter2" = Table.SplitColumn(#"Split Column by Delimiter1", "Approved Project Allocation", Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, false), {"Approved Project Allocation.1", "Approved Project Allocation.2"}),
    #"Split Column by Delimiter3" = Table.SplitColumn(#"Split Column by Delimiter2", "Approved Project Allocation.2", Splitter.SplitTextByDelimiter("%", QuoteStyle.Csv), {"Approved Project Allocation.2.1", "Approved Project Allocation.2.2"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Split Column by Delimiter3",{"Governance Role.1", "Governance Role.2.2", "Approved Project Allocation.1", "Approved Project Allocation.2.2"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns1",{{"Governance Role.2.1", "Governance % Allocation"}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Renamed Columns",{{"Approved Project Allocation.2.1", "Project % Allocation"}}),
    #"Changed Type3" = Table.TransformColumnTypes(#"Renamed Columns1",{{"Governance % Allocation", type number}, {"Project % Allocation", type number}}),
    #"Added Custom8" = Table.AddColumn(#"Changed Type3", "Base Governance %", each ([FTE] * [#"FTE reductions for SSP and/or external governance"] * 10) - (if [Contractual Base Governance Reduction] = null then 0 else [Contractual Base Governance Reduction])),
    #"Added Custom9" = Table.AddColumn(#"Added Custom8", "Total Governance %", each if [#"Governance % Allocation"] = null then 0 else [#"Governance % Allocation"]),
    #"Added Custom10" = Table.AddColumn(#"Added Custom9", "Total Project %", each if [#"Project % Allocation"] = null then 0 else [#"Project % Allocation"]),
    #"Added Custom11" = Table.AddColumn(#"Added Custom10", "Target % Teaching Load", 
    each ((70 * [FTE] * (if [#"FTE reductions for SSP and/or external governance"] = null then 0 else [#"FTE reductions for SSP and/or external governance"])) 
    - (if [#"Governance % Allocation"] = null then 0 else [#"Governance % Allocation"])
    - (if [#"Project % Allocation"] = null then 0 else [#"Project % Allocation"])
    - (if [#"Agreed Research Focused %"] = null then 0 else [#"Agreed Research Focused %"]) + (if [#"Contractual Research Reduction"] = null then 0 else [#"Contractual Research Reduction"]) - (if [#"Contractual Teaching Reduction"] = null then 0 else [#"Contractual Teaching Reduction"])
)),
    #"Added Custom12" = Table.AddColumn(#"Added Custom11", "Governance Project total percentage", each 
    ((if [#"Governance % Allocation"] = null then 0 else [#"Governance % Allocation"]) +
    (if [#"Project % Allocation"] = null then 0 else [#"Project % Allocation"]) +
    (if [#"Base Governance %"] = null then 0 else [#"Base Governance %"])) / 100
),
    #"Added Custom13" = Table.AddColumn(#"Added Custom12", "Total Research %", each 
    ([#"FTE"] * (if [#"FTE reductions for SSP and/or external governance"] = null then 0 else [#"FTE reductions for SSP and/or external governance"]) * 100) 
    - ((if [#"Target % Teaching Load"] = null then 0 else [#"Target % Teaching Load"]) 
       + (if [#"Base Governance %"] = null then 0 else [#"Base Governance %"]) 
       + (if [#"Total Governance %"] = null then 0 else [#"Total Governance %"]) 
       + (if [#"Total Project %"] = null then 0 else [#"Total Project %"]))
    - (if [#"Contractual Teaching Reduction"] = null then 0 else [#"Contractual Teaching Reduction"])
),
    #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom13",{{"Number", type text}}),
    #"Inserted Merged Column" = Table.AddColumn(#"Changed Type2", "Staff Key", each Text.Combine({[Number], Text.From([Year], "en-AU")}, "_"), type text),
    #"Added Custom7" = Table.AddColumn(#"Inserted Merged Column", "Base Governance % Percentage", each [#"Base Governance %"]/100),
    #"Added Custom14" = Table.AddColumn(#"Added Custom7", "Governance % Allocation percentage", each [#"Governance % Allocation"]/100),
    #"Removed Columns2" = Table.RemoveColumns(#"Added Custom14",{"Column36", "Column37", "Column38", "Column39", "Column40", "Column41"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Columns2", {"Staff Key"})
in
    #"Removed Duplicates"

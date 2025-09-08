let
    Source = SharePoint.Files("https://uonstaff.sharepoint.com/sites/HCISS", [ApiVersion = 15]),
    #"Filtered Rows1" = Table.SelectRows(Source, each ([Extension] = ".xlsx") and ([Name] = "WL-PowerBI Data.xlsx")),
    #"WL-PowerBI Data xlsx_https://uonstaff sharepoint com/sites/" = #"Filtered Rows1"{[Name="WL-PowerBI Data.xlsx",#"Folder Path"="https://uonstaff.sharepoint.com/sites/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"WL-PowerBI Data xlsx_https://uonstaff sharepoint com/sites/"),
    #"HCISS course data_Sheet" = #"Imported Excel Workbook"{[Item="Course data",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"HCISS course data_Sheet", [PromoteAllScalars=true]),
    #"Replaced Value" = Table.ReplaceValue(#"Promoted Headers","NCL","Newcastle City",Replacer.ReplaceText,{"Location"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value","CAL","Callaghan",Replacer.ReplaceText,{"Location"}),
    #"Replaced Value2" = Table.ReplaceValue(#"Replaced Value1","ONL","Online",Replacer.ReplaceText,{"Location"}),
    #"Replaced Value3" = Table.ReplaceValue(#"Replaced Value2","OUR","Ourimbah",Replacer.ReplaceText,{"Location"}),
    #"Replaced Value4" = Table.ReplaceValue(#"Replaced Value3","SEM1","Semester 1",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value5" = Table.ReplaceValue(#"Replaced Value4","SEM2","Semester 2",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value6" = Table.ReplaceValue(#"Replaced Value5","SUM2","Summer 2",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value7" = Table.ReplaceValue(#"Replaced Value6","SUM1","Summer 1",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value8" = Table.ReplaceValue(#"Replaced Value7","WINT","Winter",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value9" = Table.ReplaceValue(#"Replaced Value8","TRI1","Trimester 1",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value10" = Table.ReplaceValue(#"Replaced Value9","TRI2","Trimester 2",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value11" = Table.ReplaceValue(#"Replaced Value10","TRI3","Trimester 3",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value12" = Table.ReplaceValue(#"Replaced Value11","Q1","Quarter 1",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value13" = Table.ReplaceValue(#"Replaced Value12","Q2","Quarter 2",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value14" = Table.ReplaceValue(#"Replaced Value13","Q3","Quarter 3",Replacer.ReplaceText,{"Term"}),
    #"Replaced Value15" = Table.ReplaceValue(#"Replaced Value14","Q4","Quarter 4",Replacer.ReplaceText,{"Term"}),
    #"Changed Type3" = Table.TransformColumnTypes(#"Replaced Value15",{{"Year", type text}}),
    #"Inserted Merged Column" = Table.AddColumn(#"Changed Type3", "Key", each Text.Combine({[Course Code], [Term], [Location], [Year]}, "-"), type text),
    #"Inserted Merged Column1" = Table.AddColumn(#"Inserted Merged Column", "Key - No year", each Text.Combine({[Course Code], [Term], [Location]}, "-"), type text),
    #"Replaced Errors1" = Table.ReplaceErrorValues(#"Inserted Merged Column1", {{"% variance allocation to weighting", 0}}),
    #"Filtered Rows" = Table.SelectRows(#"Replaced Errors1", each ([Course Code] <> null)),
    #"Renamed Columns" = Table.RenameColumns(#"Filtered Rows",{{"Staff Mapping Notes (e.g. please provide a summary of team teaching if needed as per team teaching XLS calculators, any Casual staff expected, new course project allocations and any other relevant details)", "Notes"}, {"Core, Comp, Dirctd", "Core, Compulsory, Directed"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Proposed Coordinator - allocation", type number}, {"Team Teaching Contributor 1 allocation", type number}, {"Team Teaching Contributor 2 allocation", type number}, {"Team Teaching Contributor 3 allocation", type number}, {"Team Teaching Contributor 4 allocation", type number}, {"Team Teaching Contributor 5 allocation", type number}, {"Team Teaching Contributor 6 allocation", type number}, {"Team Teaching Contributor 7 allocation", type number}, {"Team Teaching Contributor 8 allocation", type number}, {"Team Teaching Contributor 9 allocation", type number}, {"Team Teaching Contributor 10 allocation", type number}, {"Team Teaching Contributor 11 allocation", type number}, {"Team Teaching Contributor 12 allocation", type number}, {"Team Teaching Contributor 13 allocation", type number}, {"Team Teaching Contributor 14 allocation", type number}, {"% Casual Staffing Forecast", type number}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "Total WL %", each (List.Sum({
    if [#"Proposed Coordinator - allocation"] = null then 0 else [#"Proposed Coordinator - allocation"],
    if [Team Teaching Contributor 1 allocation] = null then 0 else [Team Teaching Contributor 1 allocation],
    if [Team Teaching Contributor 2 allocation] = null then 0 else [Team Teaching Contributor 2 allocation],
    if [Team Teaching Contributor 3 allocation] = null then 0 else [Team Teaching Contributor 3 allocation],
    if [Team Teaching Contributor 4 allocation] = null then 0 else [Team Teaching Contributor 4 allocation],
    if [Team Teaching Contributor 5 allocation] = null then 0 else [Team Teaching Contributor 5 allocation],
    if [Team Teaching Contributor 6 allocation] = null then 0 else [Team Teaching Contributor 6 allocation],
    if [Team Teaching Contributor 7 allocation] = null then 0 else [Team Teaching Contributor 7 allocation],
    if [Team Teaching Contributor 8 allocation] = null then 0 else [Team Teaching Contributor 8 allocation],
    if [Team Teaching Contributor 9 allocation] = null then 0 else [Team Teaching Contributor 9 allocation],
    if [Team Teaching Contributor 10 allocation] = null then 0 else [Team Teaching Contributor 10 allocation],
    if [Team Teaching Contributor 11 allocation] = null then 0 else [Team Teaching Contributor 11 allocation], 
    if [Team Teaching Contributor 12 allocation] = null then 0 else [Team Teaching Contributor 12 allocation],
    if [Team Teaching Contributor 13 allocation] = null then 0 else [Team Teaching Contributor 13 allocation],
    if [Team Teaching Contributor 14 allocation] = null then 0 else [Team Teaching Contributor 14 allocation]
}))/100),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Discipline", each null),
    #"Removed Columns2" = Table.RemoveColumns(#"Added Custom1",{"Forecast Course size", "Forecast Base course (value) % allocated", "Forecast overall course (value) % allocation", "% variance allocation to weighting", "% Casual Staffing Forecast"}),
    #"Added Conditional Column" = Table.AddColumn(#"Removed Columns2", "Forecast Course size", each if [Forecast Enrols] <= 34 then "Small" else if [Forecast Enrols] <= 74 then "Medium" else if [Forecast Enrols] <= 299 then "Large" else if [Forecast Enrols] >= 300 then "X-Large" else "Unknown"),
    #"Added Conditional Column1" = Table.AddColumn(#"Added Conditional Column", "Forecast Base course (value) % allocated", each if [#"Forecast Course size"] = "Small" then 5 else if [#"Forecast Course size"] = "Medium" then 10 else if [#"Forecast Course size"] = "Large" then 20 else if [#"Forecast Course size"] = "X-Large" then 30 else "Unknown"),
    #"Added Custom2" = Table.AddColumn(#"Added Conditional Column1", "Forecast overall course (value) % allocation", each [#"Forecast Base course (value) % allocated"]*[MULTIPLIER]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom2",{{"Forecast Base course (value) % allocated", type number}, {"Forecast overall course (value) % allocation", type number}, {"% change if required at census", type number}}),
    #"Added Custom3" = Table.AddColumn(#"Changed Type1", "% variance allocation to weighting", 
     each ((if [Team Teaching Contributor 14 allocation] = null then 0 else [Team Teaching Contributor 14 allocation]) + 
         (if [Team Teaching Contributor 13 allocation] = null then 0 else [Team Teaching Contributor 13 allocation]) + 
         (if [Team Teaching Contributor 12 allocation] = null then 0 else [Team Teaching Contributor 12 allocation]) + 
         (if [Team Teaching Contributor 11 allocation] = null then 0 else [Team Teaching Contributor 11 allocation]) + 
         (if [Team Teaching Contributor 10 allocation] = null then 0 else [Team Teaching Contributor 10 allocation]) + 
         (if [Team Teaching Contributor 9 allocation] = null then 0 else [Team Teaching Contributor 9 allocation]) + 
         (if [Team Teaching Contributor 8 allocation] = null then 0 else [Team Teaching Contributor 8 allocation]) + 
         (if [Team Teaching Contributor 7 allocation] = null then 0 else [Team Teaching Contributor 7 allocation]) + 
         (if [Team Teaching Contributor 6 allocation] = null then 0 else [Team Teaching Contributor 6 allocation]) + 
         (if [Team Teaching Contributor 5 allocation] = null then 0 else [Team Teaching Contributor 5 allocation]) + 
         (if [Team Teaching Contributor 4 allocation] = null then 0 else [Team Teaching Contributor 4 allocation]) + 
         (if [Team Teaching Contributor 3 allocation] = null then 0 else [Team Teaching Contributor 3 allocation]) + 
         (if [Team Teaching Contributor 2 allocation] = null then 0 else [Team Teaching Contributor 2 allocation]) + 
         (if [Team Teaching Contributor 1 allocation] = null then 0 else [Team Teaching Contributor 1 allocation]) + 
         (if [#"Proposed Coordinator - allocation"] = null then 0 else [#"Proposed Coordinator - allocation"]) - 
         (if [#"Forecast overall course (value) % allocation"] = null then 0 else [#"Forecast overall course (value) % allocation"])-
         (if [#"% change if required at census"] = null then 0 else [#"% change if required at census"]))
    ),
#"Added Custom 5" = Table.AddColumn(#"Added Custom3", "% Casual Staffing Forecast", 
        each 
        let
            CasualAllocations = [
                ProposedCoordinator = if Record.HasFields(_, "Proposed Coordinator") and _[Proposed Coordinator] = "Casual" then _[#"Proposed Coordinator - allocation"] else 0,
                Contributor1 = if Record.HasFields(_, "Team Teaching Contributor 1") and _[Team Teaching Contributor 1] = "Casual" then _[#"Team Teaching Contributor 1 allocation"] else 0,
                Contributor2 = if Record.HasFields(_, "Team Teaching Contributor 2") and _[Team Teaching Contributor 2] = "Casual" then _[#"Team Teaching Contributor 2 allocation"] else 0,
                Contributor3 = if Record.HasFields(_, "Team Teaching Contributor 3") and _[Team Teaching Contributor 3] = "Casual" then _[#"Team Teaching Contributor 3 allocation"] else 0,
                Contributor4 = if Record.HasFields(_, "Team Teaching Contributor 4") and _[Team Teaching Contributor 4] = "Casual" then _[#"Team Teaching Contributor 4 allocation"] else 0,
                Contributor5 = if Record.HasFields(_, "Team Teaching Contributor 5") and _[Team Teaching Contributor 5] = "Casual" then _[#"Team Teaching Contributor 5 allocation"] else 0,
                Contributor6 = if Record.HasFields(_, "Team Teaching Contributor 6") and _[Team Teaching Contributor 6] = "Casual" then _[#"Team Teaching Contributor 6 allocation"] else 0,
                Contributor7 = if Record.HasFields(_, "Team Teaching Contributor 7") and _[Team Teaching Contributor 7] = "Casual" then _[#"Team Teaching Contributor 7 allocation"] else 0,
                Contributor8 = if Record.HasFields(_, "Team Teaching Contributor 8") and _[Team Teaching Contributor 8] = "Casual" then _[#"Team Teaching Contributor 8 allocation"] else 0,
                Contributor9 = if Record.HasFields(_, "Team Teaching Contributor 9") and _[Team Teaching Contributor 9] = "Casual" then _[#"Team Teaching Contributor 9 allocation"] else 0,
                Contributor10 = if Record.HasFields(_, "Team Teaching Contributor 10") and _[Team Teaching Contributor 10] = "Casual" then _[#"Team Teaching Contributor 10 allocation"] else 0,
                Contributor11 = if Record.HasFields(_, "Team Teaching Contributor 11") and _[Team Teaching Contributor 11] = "Casual" then _[#"Team Teaching Contributor 11 allocation"] else 0,
                Contributor12 = if Record.HasFields(_, "Team Teaching Contributor 12") and _[Team Teaching Contributor 12] = "Casual" then _[#"Team Teaching Contributor 12 allocation"] else 0,
                Contributor13 = if Record.HasFields(_, "Team Teaching Contributor 13") and _[Team Teaching Contributor 13] = "Casual" then _[#"Team Teaching Contributor 13 allocation"] else 0,
                Contributor14 = if Record.HasFields(_, "Team Teaching Contributor 14") and _[Team Teaching Contributor 14] = "Casual" then _[#"Team Teaching Contributor 14 allocation"] else 0
            ]
        in
            List.Sum(Record.FieldValues(CasualAllocations))
    ),
    #"Added Custom5" = Table.AddColumn(#"Added Custom 5", "Course Loop CC", each if [Externally Funded Coordinator] <> null and [Externally Funded Coordinator] <> "" 
then [Externally Funded Coordinator] 
else [Proposed Coordinator]),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Added Custom5", "Proposed Coordinator", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Proposed Coordinator Name", "Proposed Coordinator Number"}),
    #"Split Column by Delimiter1" = Table.SplitColumn(#"Split Column by Delimiter", "Team Teaching Contributor 1", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 1 Name", "Team Teaching Contributor 1 Number"}),
    #"Split Column by Delimiter2" = Table.SplitColumn(#"Split Column by Delimiter1", "Team Teaching Contributor 2", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 2 Name", "Team Teaching Contributor 2 Number"}),
    #"Split Column by Delimiter3" = Table.SplitColumn(#"Split Column by Delimiter2", "Team Teaching Contributor 3", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 3 Name", "Team Teaching Contributor 3 Number"}),
    #"Split Column by Delimiter4" = Table.SplitColumn(#"Split Column by Delimiter3", "Team Teaching Contributor 4", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 4 Name", "Team Teaching Contributor 4 Number"}),
    #"Split Column by Delimiter5" = Table.SplitColumn(#"Split Column by Delimiter4", "Team Teaching Contributor 5", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 5 Name", "Team Teaching Contributor 5 Number"}),
    #"Split Column by Delimiter6" = Table.SplitColumn(#"Split Column by Delimiter5", "Team Teaching Contributor 6", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 6 Name", "Team Teaching Contributor 6 Number"}),
    #"Split Column by Delimiter7" = Table.SplitColumn(#"Split Column by Delimiter6", "Team Teaching Contributor 7", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 7 Name", "Team Teaching Contributor 7 Number"}),
    #"Split Column by Delimiter8" = Table.SplitColumn(#"Split Column by Delimiter7", "Team Teaching Contributor 8", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 8 Name", "Team Teaching Contributor 8 Number"}),
    #"Split Column by Delimiter9" = Table.SplitColumn(#"Split Column by Delimiter8", "Team Teaching Contributor 9", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 9 Name", "Team Teaching Contributor 9 Number"}),
    #"Split Column by Delimiter10" = Table.SplitColumn(#"Split Column by Delimiter9", "Team Teaching Contributor 10", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 10 Name", "Team Teaching Contributor 10 Number"}),
    #"Split Column by Delimiter11" = Table.SplitColumn(#"Split Column by Delimiter10", "Team Teaching Contributor 11", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 11 Name", "Team Teaching Contributor 11 Number"}),
    #"Split Column by Delimiter12" = Table.SplitColumn(#"Split Column by Delimiter11", "Team Teaching Contributor 12", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 12 Name", "Team Teaching Contributor 12 Number"}),
    #"Split Column by Delimiter13" = Table.SplitColumn(#"Split Column by Delimiter12", "Team Teaching Contributor 13", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 13 Name", "Team Teaching Contributor 13 Number"}),
    #"Split Column by Delimiter14" = Table.SplitColumn(#"Split Column by Delimiter13", "Team Teaching Contributor 14", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Team Teaching Contributor 14 Name", "Team Teaching Contributor 14 Number"}),
    #"Split Column by Delimiter15" = Table.SplitColumn(#"Split Column by Delimiter14", "New Course Developer 1", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"New Course Developer 1 Name", "New Course Developer 1 Number"}),  
    #"Split Column by Delimiter16" = Table.SplitColumn(#"Split Column by Delimiter15", "New Course Developer 2", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"New Course Developer 2 Name", "New Course Developer 2 Number"}),
    #"Split Column by Delimiter17" = Table.SplitColumn(#"Split Column by Delimiter16", "New Course Developer 3", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"New Course Developer 3 Name", "New Course Developer 3 Number"}),
    #"Split Column by Delimiter18" = Table.SplitColumn(#"Split Column by Delimiter17", "Course Loop CC", Splitter.SplitTextByEachDelimiter({"_"}, QuoteStyle.Csv, true), {"Course Loop CC.1", "Course Loop CC.2"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Split Column by Delimiter18",{{"Course Loop CC.1", "CL Course Coordinator"}, {"Course Loop CC.2", "CL Course Coordinator Number"}}),
    #"Added Custom4" = Table.AddColumn(#"Renamed Columns1", "CC Staff Key", each [CL Course Coordinator Number]&"_"&[Year]),
    #"Replaced Value16" = Table.ReplaceValue(#"Added Custom4","GOSF","Gosford",Replacer.ReplaceText,{"Location"}),
    #"Replaced Value17" = Table.ReplaceValue(#"Replaced Value16","MID","Midyear Session",Replacer.ReplaceText,{"Term"}),
    #"Added Custom6" = Table.AddColumn(#"Replaced Value17", "Enrolment numbers", each if [Actual Census Enrols] <> null and [Actual Census Enrols] <> "" then [Actual Census Enrols] else [Forecast Enrols]),
    #"Duplicated Column" = Table.DuplicateColumn(#"Added Custom6", "Delivery", "Delivery - Copy"),
    #"Renamed Columns2" = Table.RenameColumns(#"Duplicated Column",{{"Delivery - Copy", "Delivery Mode"}}),
    #"Replaced Value18" = Table.ReplaceValue(#"Renamed Columns2","SON","Scheduled Online",Replacer.ReplaceText,{"Delivery Mode"}),
    #"Replaced Value19" = Table.ReplaceValue(#"Replaced Value18","MIX","Blended Learning",Replacer.ReplaceText,{"Delivery Mode"}),
    #"Replaced Value20" = Table.ReplaceValue(#"Replaced Value19","F2F","Face to Face",Replacer.ReplaceText,{"Delivery Mode"}),
    #"Replaced Value21" = Table.ReplaceValue(#"Replaced Value20","FLX","Flexible Online",Replacer.ReplaceText,{"Delivery Mode"}),
    #"Replaced Value22" = Table.ReplaceValue(#"Replaced Value21","OIN","Online with Intensive",Replacer.ReplaceText,{"Delivery Mode"}),
    #"Replaced Value23" = Table.ReplaceValue(#"Replaced Value22","SIM","Simultaneous",Replacer.ReplaceText,{"Delivery Mode"}),
    #"Duplicated Column1" = Table.DuplicateColumn(#"Replaced Value23", "Course Code", "Course Code - Copy"),
    #"Split Column by Character Transition" = Table.SplitColumn(#"Duplicated Column1", "Course Code - Copy", Splitter.SplitTextByCharacterTransition((c) => not List.Contains({"0".."9"}, c), {"0".."9"}), {"Course Code - Copy.1", "Course Code - Copy.2"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Split Column by Character Transition",{{"Course Code - Copy.1", "Subject Area"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns3",{"Course Code - Copy.2"})
in
    #"Removed Columns"

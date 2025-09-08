# University-Workload-PowerBI-dashboard
The University is required to plan and record the workload for each school for all course and academic staff throughout the university. Throughout my time working in one of these schools I was tasked with creating a way to visualise this data for managers of the school to be able to report on courses, enrolments, staffing, financial costs, funding, projects and more. 

The issue with the university and many of its systems are they do not visualise any of their data well. Along with this only a very small number of their many systems are integrated.

Part of the decision I was hired for my role within the school was my ability to create Power Bi dashboards and compare and transform data into different systems.

When I first joined the school there was a excel spreadsheet which was dirty, inaccurate and needing a lot of love. This spreadsheet had a bone of the data the school used to plan out future years. Course codes, staffing, course sizes, contract details and workload spreads.

Before I could start my job in transforming the data and having the ability to put our data into the required different systems I had to review and clean the data. I was lucky that the manager staff who created the bones of the excel spreadsheet was still around and I sat down with him and explained all the errors and discrepancies within the school’s data. Together we cleaned all the data and add some more unique data such as staff number as a unique identifier and a course offering key which was unique. This key was created by adding the course code, location, term and year together. As with all these data points put together, we could only have one primary key for the couse data table. e.g. CMNS1234-CAL-Sem2-2025

Once the data was clean and I was happy it was accurate after speaking with management staff. I used this data to import our Course Availability Listing into a system 'CourseLoop', this system sadly has no import functionality but an export. With this data and a few x-look ups against my new trust primary key we were cooking with Fire.
After being happy with the data, the excel was shared with Subject Area staff who look after each subject within the school. The issue now was the excel had too many columns, the data was hard to read, and anyone could edit cells to break the spreadsheet.

With these issues present I had the idea to create a Power BI dashboard with would allow all the school staff to easily have the ability to check what courses they will be teaching in as well and a simplistic view of their workload breakdown. Which is a split of Teaching, Leadership and Research.
I uploaded the workload data to the schools secure SharePoint site and locked the workbook behind a password. Each row was also locked down further using conditional formatting, to ensure data types would be correct and future inputs wouldn't break the excel or Power BI feed. Lastly, I set-up a power automate script to back up the excel file daily outside of normal work hours.

Once i was happy with the schools workload excel file housing our data, I got to work creating the Power Bi dashboard & report.

As all of the course data was together, I started with designing an individual course data page which would allow anyone with access to search for a course using many filters and slicers. This was quite simple as all the data was set-up and ready to go. The biggest challenge in this page was creating a measure to calculate the difference in the forecasted enrolments for future predictions for future years and past enrolment data for terms which had already ran. I had to create a new column which only put the forecasted enrolment data into that column if there was no past data in the other column for the same course offering. I would then minus this new enrolment numbers column from the forecasted enrolment data to give the variance in the forecasted data compared to the actual enrolment numbers for that course.

*Here is the DAX
Difference between Forecasted enrols and census enrols = 
SUM('course data'[Enrolment numbers]) - SUM('course data'[Forecast Enrols])

I also had another fun time adding the word students to a numeric data type. 
DAX
Total Forecasted Student Enrolments = 
SUMX(
    SUMMARIZE(
        'course data', 
        'course data'[Key], 
        "UniqueEnrols", 
        MAX('course data'[Forecast Enrols])
    ), 
    [UniqueEnrols]
)

Next was the individual staff data. This page would allow for any staff member the ability to go see what courses they were teaching into and the total breakdown of their workload in all categories. 
My biggest learning experience with this page was combining 14 columns of staff data into one column to allow a search for all staff within one course offering. I overcame this by learning a hand function of unpivoting columns. 
To have the ability to perform unpivoting i needed to first duplicate the course data table, which lead me to have a new table which i would then need to model back to the other tables with a relationship. I was prepared for this and used my unique keys i had created earlier. 
In this new table I unpivoted both the Allocated staffs name and workload number assigned to them. Matched it back together and delimited the staff members name from either staff number to allow for a new drop down menu which would allow to search for anytime that staff member popped up. 
I designed a dashboard which would allow staff for a one stop shop for all their data and threw in some conditional formatting to show if a staff member was over or under their total workload by making a green to red colour scale. I also added a workload indicator to show the percent of workload that staff member is working within that course offering.

Now we had the staff happy and able to search their courses and working data, I was tasked with creating reports on the schools data for stakeholder reporting. First, I started with the School and Disciple overview page which shows the whole schools workload breakdowns and splits. This page needed to be extremely accurate and have no fluff. 
It needed to express the school as to the shifts in workload breakdowns and the directions the school wanted to steer towards to stay competitive. 
Using the year filter one can easily see how many staff we have for each year, the amount of workload we are allocating to new courses, teaching, Leadership and governance along with the complexity of the courses. Creating this page required a lot of DAX and double and triple checking of calculations.

The 2nd last page I designed 'Yearly comparison' was requested by our Head of School. She was asked how the school was shifting and the trajectory we were heading. The school had pressure to lower the number of courses with small enrolment numbers and show we were consolidating as well as making improvements in enrolments year on year. 
This page I designed to show all the enrolment against the courses and course offerings per year. The total number of academic staff and enrolments over the life of the spreadsheet (2024 to 2026) and how each individual disciple and location was faring. The report was a hit and said to have saved the school from further scrutiny, as stakeholders could see that the school was making the right moves and couldn't fault our data.

The last page I created 'WAMS' is for myself and my team. We are tasked quarterly to import the school’s workload data (all this data I have created this for) over into a system 'WAMS' this system sucks and has no import functionality. So therefore, as we would need to manually enter the data, I created a page which would show us exactly what we would need for a one stop shop. We can search by all courses, staff, subect area, term, location and year. The DAX i created for the cards allows to quickly be able to see a staff member breakdown and total workload allocation which we can quickly cross reference with the WAMS system.

To wrap up this dashboard/report it is used daily by stakeholders, managers, academic staff and professional staff within the school at the university. This data being so accurate and visually transparent has allowed my school, which houses the highest number of courses and course offerings and courses at different locations the ability to keep working and pushing forward. Without this data the school would be forced to axe more courses and staff. This is the real motivation for the creation of this report, to ensure job security behind true data for the whole school.

On another point the rest of the university has been complaining about the current Workload reporting system WAMS and designs for a new in-house solution have been in the talks. Inspiration has come from my dashboard, and a back-end report is also in the works which is also being designed from my report. I am current working alongside the Digital technology solutions project team who is tasked with this project.


Tim Regan
8/9/25

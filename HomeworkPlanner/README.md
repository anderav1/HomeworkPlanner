#  Homework Planner iOS App
## Purpose
Keep track of upcoming assignments

## Audience
University & high school students

## User Stories
* User can add an assignment with a title, course, deadline (date & time), and optional description/notes and reminder alarm
* Assignment data is persisted to core data
* User can flag high-priority assignments *(not yet implemented)*
* User can view and sort a list of all upcoming assignments (sort by deadline, name, course, priority)
* User can filter the assignment list: by course, high priority *(not yet implemented)*, due today, due tomorrow, due this week, or view all
* User can edit and delete existing assignments or mark them as completed
* User can configure a course list that can be quickly referenced during assignment creation

## Stretch Goals
* User can view a calendar of their upcoming assignments *(top-priority stretch goal; this is the one I most want to implement, if possible)
 * The calendar can only be viewed at this time, but in the future I would like to add functionality so that the user can tap a calendar cell to see a popover view listing all the homework tasks due as well as any reminder alarms set for that date
* User can search the assignment list for a specific assignment using keywords from the title, course, or description fields
  * The search bar above the task list filters which assignments are displayed as soon as the user starts typing
* Assignment list delete mode: user can check a box next to each assignment to be deleted, then delete them all with one button click
  * Implemented via the editing bar button item in the navigation bar
  * Edit mode is available for both the assignment list and the course list

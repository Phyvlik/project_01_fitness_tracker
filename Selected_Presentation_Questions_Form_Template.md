# Selected Presentation Questions Form

## Course Information
- Course Name: Mobile App Development
- Course Section: 004
- Instructor: L. Henry
- Semester/Term: Spring 2026

## Team Information
- Group Name: FitQuest Team
- App/Project Title: Fitness Quest & Training Challenge Hub
- Presentation Date: 3/24/26

### Team Members
1. Vivek Patel
2. Edward Forrester

## Selected Questions (Choose 10–15)

Use this section to list the specific Project1Q&A questions your team selected for presentation.

1. Question: What are the key advantages of using Flutter for this cross-platform project?
   - Category: Flutter Framework & Cross-Platform Concepts
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - UI screenshot: ![Q1](<selected presentation questions images/05_add_workout_form_initial.png>)
     - Code: `lib/main.dart`, `lib/widgets/main_navigation.dart`
2. Question: How does your widget tree design affect rendering behavior and performance?
   - Category: Flutter Framework & Cross-Platform Concepts 
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - UI screenshot: ![Q2](<selected presentation questions images/q2.png>)
     - Code: `lib/widgets/main_navigation.dart`, `lib/screens/home_screen.dart`

3. Question: Which state management technique did you choose and why?​
   - Category: STATE MANAGEMENT​
   - Team Member Responsible: Edward Forrester
   - Evidence to Show (code file/commit/UI/screenshot):
     - UI screenshot: ![Q3](<selected presentation questions images/q3.png>)
     - Code: `lib/providers/app_provider.dart`

4. Question: Describe one state-flow interaction from user action to UI update in your app.
   - Category: STATE MANAGEMENT​
   - Team Member Responsible: Edward Forrester
   - Evidence to Show (code file/commit/UI/screenshot):
     - UI screenshot: ![Q4](<selected presentation questions images/q4.png>)
     - Trace files: `lib/screens/add_workout_screen.dart` → `lib/providers/app_provider.dart` → `lib/db/database_helper.dart`

5. Question:How did you make the interface intuitive and responsive across device sizes/orientations?
   - Category:UI/UX DESIGN​
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - UI screenshot: ![Q5](<selected presentation questions images/q5.png>)
     - Code: `lib/screens/insights_screen.dart`

6. Question:What usability improvement did you make after testing feedback?​
   - Category:UI/UX DESIGN​
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - UI screenshot: ![Q6](<selected presentation questions images/q5.png>)
     - Commit example: `946c64b` (home overflow fix)

7. Question:Explain your local data structure (tables/columns/keys or preference groups).​
   - Category: LOCAL DATA PERSISTENCE​
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - Data diagram screenshot: ![Q7](<selected presentation questions images/q7_and_17.png>)
     - Code: `lib/db/database_helper.dart`

8. Question:How are CRUD operations implemented and validated in your app?
   - Category: LOCAL DATA PERSISTENCE​
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - UI screenshot: ![Q8](<selected presentation questions images/05_add_workout_form_initial.png>)
     - Code: `lib/screens/add_workout_screen.dart`, `lib/providers/app_provider.dart`

9. Question:VERSION CONTROL​
   - Category: Share one meaningful commit message and explain why it communicates value clearly.​
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - Screenshot: ![Q9](<selected presentation questions images/q9.png>)
     - Commit examples: `21436fd`, `e680ca1`, `624188c`

10. Question:How were responsibilities divided, and how did you ensure fair technical ownership?​
   - Category:TEAM COLLABORATION​
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
    - Team ownership slide screenshot: ![Q10 Team Ownership](<selected presentation questions images/teamownership.png>)
     - Docs: `README.md` team section

11. Question:Which SDLC approach best matches your team workflow, and why?
   - Category:SDLC PRACTICES​
   - Team Member Responsible: Edward Forrester
   - Evidence to Show (code file/commit/UI/screenshot):
     - Artifact: `ARCHITECTURE.md`, `PROJECT_REPORT.md`, git commit timeline

12. Question:How did you decide what to include in README and technical documentation for maintainability?
   - Category:TECHNICAL DOCUMENTATION​
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - Screenshots: ![Q12](<selected presentation questions images/q12.png>) and ![Q12-2](<selected presentation questions images/q12_2.png>)
     - Doc file: `README.md`

13. Question:Walk through one complete feature trace using your actual code: start from a user tap, show the triggering widget, state update logic, data-layer call, and final UI render. Identify the exact files/classes involved at each step.​
   - Category: IMPLEMENTATION DEFENSE
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - Screenshots: ![Q13](<selected presentation questions images/q13.png>) and ![Q13-2](<selected presentation questions images/q13_2.png>)
     - Trace files: `lib/screens/add_workout_screen.dart` → `lib/providers/app_provider.dart` → `lib/db/database_helper.dart` → `lib/screens/home_screen.dart`

14. Question: Present one bug your team introduced and fixed. Show the related commit(s), explain the root cause, why the first approach failed (if applicable), and how the final fix changed runtime behavior.​
   - Category: IMPLEMENTATION DEFENSE
   - Team Member Responsible: Edward Forrester
   - Evidence to Show (code file/commit/UI/screenshot):
     - Fix commit: `624188c` (y-axis label rendering)
     - Before/after demo in Insights chart UI
   
15. Question: Identify one part of your app that is currently most fragile. Propose a concrete refactor plan with ordered steps, expected impact, and how you would verify improvement using your current test/demo workflow.
   - Category: IMPLEMENTATION DEFENSE
   - Team Member Responsible: Edward Forrester
   - Evidence to Show (code file/commit/UI/screenshot):
     - Screenshot: ![Q15](<selected presentation questions images/q_15.png>)
     - Refactor target: `lib/screens/insights_screen.dart`
   
   16. Question:Compare two implementation options your team considered. Use project-specific constraints to justify the final choice and one trade-off you accepted.
   - Category: IMPLEMENTATION DEFENSE
   - Team Member Responsible: Edward Forrester
   - Evidence to Show (code file/commit/UI/screenshot):
     - Compare: `sqflite` local-first vs cloud backend (documented in `ARCHITECTURE.md`)
   
   17. Question:Demonstrate a data integrity scenario. Explain exactly where validation occurs and how the app prevents inconsistent state.
   - Category: IMPLEMENTATION DEFENSE
   - Team Member Responsible: Vivek Patel
   - Evidence to Show (code file/commit/UI/screenshot):
     - Screenshots: ![Q17](<selected presentation questions images/q17.png>) and ![Q7&17](<selected presentation questions images/q7_and_17.png>)
     - Validation code: `lib/screens/add_workout_screen.dart`, `lib/models/workout.dart`

  
## Final Confirmation
- [ ] This form includes the questions selected for our presentation.
- [ ] We will submit this form at the same time as our project package.

Instruction Statement:
Please include a Selected Presentation Questions Form with your project. This document must list the questions you have chosen to incorporate into your presentation and should be submitted at the same time as your project.

# snse
## Get a sense for how you're feeling.

## About
Snse is a simple app to track your mood, capture your thoughts, track your water consumption, or be your color palette.

How often have you thought, "I should journal more." but never get around to it; or when you do, have trouble articulating your thoughts into words.
I wanted a way to capture some of the less articulate sentiments.
 * **How are you feeling?:** 😞, 😐, 😊. 
   - No value judgement for any of the options. No, "What's wrong", or "Why not happy?", no explanation needed.
 * **0 - 100:** This is a slider that _doesn't_ show your selected value, on purpose. 
   - We are constantly innundated by micro-stresses, pressures to conform or be perfect. We rarely feel precisely a number, so there isn't any value in trying to record one. Feelings have rough edges, this is to aim at that blurry edge.
 * **Color?:** Sometimes a season is tinted with a hue, or a certain shade really stands out to you. 
   - For me, Summer feels blue, green, and bright yellow. Is a specific color speaking to you, pick it, and save it for later.
   - Color is the only one that has an additional affect. When you select a color the "tint" of all the UI elements is set to your color. (Sometimes this makes interacting with the rest of the form difficult, so you may want to set it last if you are feeling a particularly bright color.)
 * **Have you recently drunk water?:** Water consumption has a huge impact on our mood ([link](https://www.ncbi.nlm.nih.gov/pubmed/25963107)). Highlighting the correlation of mood vs hydration is something I wanted to call out. 
   - Adding that as its own entry field was done with intent to influence you to drink more water.
 * **Elaborate?"** A traditional journal entry. Write what you want, it will be captured.
 
**None of the values are required to save a sentiment.** Sometimes just showing up is all that needs to be said.

## Technology/Features:
*Snse* is localized into multiple languages. As of [v1](https://github.com/BlakeBarrett/snse-ios/releases/tag/v1.0), translations are included for: English, Spanish, German and Russian.
 * Entry form:
   - The entry form uses auto-layout to align the elements and provide for a responsive layout on everything from the tiniest iPod touch to the largest iPad Pro; and everything in between.
   - The same entry form is used as the history view. 
   - Any value not provided during the initial entry will be excluded. This is accomplished by using a UIStackView.
   - The entry form is embedded in a UIScrollView. This was more difficult than I had expected; embeding a View which is sized by auto-layout in a scroll view, but it works.
   - Applying focus to the "Elaborate" text entry field will cause the scroll-view to position itself, such that the cursor is visible above the keyboard. 
     - This was the biggest P.I.T.A. of the entire project.
 * History:
   - Your sentiments are your own and nobody else'; that's why they are all saved on your device and your device only. Sentiments are saved on your device and only your device (I think they may get backed up, by Apple, if you use iCloud backup). 
   - Your sentiments are protected from prying eyes by Apple's biometric authentication. If you are using a legacy device that does not support FaceID or TouchID, or if you are not enrolled in either of those programs, passcode authentication is used by default.
   - Sometimes you just need to purge a single entry; maybe you were just showing someone how it works. Individual rows can be removed by dragging it to the left.
   

[![App Store](https://developer.apple.com/app-store/marketing/guidelines/images/badge-example-preferred.png)](https://itunes.apple.com/us/app/snse/id1442747058?ls=1&mt=8)

## Technology/Features:

 ## Entry form:
   - The entry form uses auto-layout to align the elements and provide for a responsive layout on everything from the tiniest iPod touch to the largest iPad Pro; and everything in between.
   - The same entry form is used as the history view. 
   - Any value not provided during the initial entry will be excluded. This is accomplished by using a `UIStackView`.
   - The entry form is embedded in a `UIScrollView`. This was more difficult than I had expected; embeding a view which is sized by auto-layout in a scroll view, but it works.
   - Applying focus to the "Elaborate" text entry field will cause the scroll-view to position itself, such that the cursor is visible above the keyboard. 
     - This was the biggest P.I.T.A. of the entire project.
 
 ## History:
   - Your sentiments are your own and nobody else'; that's why they are all saved on your device and your device only. Sentiments are saved on your device and only your device (I think they may get backed up, by Apple, if you use iCloud backup). 
   - Your sentiments are protected from prying eyes by Apple's biometric authentication. If you are using a legacy device that does not support FaceID or TouchID, or if you are not enrolled in either of those programs, passcode authentication is used by default.
   - Sometimes you just need to purge a single entry; maybe you were just showing someone how it works. Individual rows can be removed by dragging it to the left.
   
## Color Picker:
  - There is no default "Color Picker" in iOS, so I had to hack one together based on code samples found on StackOverflow, and making it behave the way I wanted. 
    - Links to original stackoverflow answers are added as comments in code.

## i18n & l10n (Internationalization and Localization)
 - *Snse* is localized into multiple languages. As of [v1](https://github.com/BlakeBarrett/snse-ios/releases/tag/v1.0), translations are included for: 
   - English
   - Spanish
   - German
   - Russian
 - All dates are formatted using a `DateFormatter` set to the device's `Locale`.


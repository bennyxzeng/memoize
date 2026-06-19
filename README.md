# Memoize Flashcard App

## Team Members

Name(s): Eric Li, Benjamin Zeng



# Purpose of the App
- The name of our app is called Memoize. It is a flashcard app designed and catered to help students and any curious learners with providing them a way to practice spaced-reptition memorization for vocabulary, concepts, or definitions. All users can create a deck in which they can then add flashcards that can contain multiple definitions and add an optional hint if they desired to their deck and then use our practice mode where they can go over each card one at a time. We pull our definitions from a free dictionary API.

# Build Instructions
1) Clone the repository to an IDE of your choice.
2) Then to run our app, make sure you are in the project root of the file (or in the same level where our pubspec.yaml is stored). Then run 'flutter pub get' in your terminal to install all necessary dependencies to run our app.
3) Next, in your terminal, run the following command, 'dart run build_runner build' to generate the Drift Database code.
4) Lastly, you can now finally run 'flutter run' to access and interact with our app!

# Requirements
- NO API keys required.
- An iOS or Android Device.
- Flutter and Dart required.
- Use an IDE like VSCode to run the app.

# Features
- The ability to create, edit, organize, and practice your flashcards all on your mobile device.
- Lookup definitions of terms when creating a new flashcard via Dictionary API calls.
- Add multiple definitions to a flashcard.
- Undo deletion of a deck or flashcard.
- Light and Dark Mode Theme Toggle.
- Multiple language support for our app UI.  (English, Spanish, and Chinese)
- Users data are stored locally on their device using Drift.
- In practice mode, you are able to long press on the screen for a hint, double tap to skip, shake to shuffle the deck, and also swipe left and right to move on to the next flashcard.
- Semantics labeled added throughout the app for accessibility and screen readers.


# Project Layout
- The project layout is structured in a very well organized manner. For anyone who view this code, we personally made it so that most required features has their own folder and files associated with it. For example, for the requirement of querying web services using APIs, since we decided on using a dictionary API to get the definitions. We created a dictionary folder and inside that folder contain the dictionary_api.dart file. Some tradeoffs of this is that instead of having multiple files for example having a seperate file for the Tables for the database like we did in our Journal Assignment. We decided to put that all in one file as long as it is well documented.
- lib/main.dart: Where the entry point of our app starts. This is where we use a MultiProvider to wire up all of our providers. Also builds the light and dark mode theme for our app.
- lib/canvas/lightbulb_hint_icon.dart: This file is to fulfill the 'Drawing with Canvas' requirement where we drew up a custom lightbulb icon used for our hint overlay for our flashcards.
- lib/database: This folder and all associated files within this folder fulfills our requirement on 'Data Persistence'. This is where we store our Drift Database. We incorporated three different tables; Decks, Cards, and the Cards Definitions.
- lib/dictionary/dictionary_api.dart: This file is for fulfilling the 'Querying Web Services using APIs' requirement. This contains our free dictionary API where we use it to fetch definitions.
- lib/language: This folder and all associated files within this folder fulfills our requirement on 'Internationlization'. This is where we store the localization files that are necessary for users of our app to use the app in their desire language. We currently only support English, Spanish, and Chinese but we can easily expand on this.
- lib/providers/app_models.dart: This is mainly used to group the Card with its associated Card Definition(s) together.
- lib/providers/card_provider.dart: This Provider handles all kind of card operations. Such as loading all the cards and definition ready for practice, and deleting a card from the deck.
- lib/providers/deck_provider.dart: This Provider handles all kind of deck operations. Such as rendering all the decks on the home screen, deleting a deck, and undoing the action of deleting a deck.
- lib/providers/language_provider.dart: This Provider manages the app language based on user's preference. Changes all UI to match the language that is selected. 
- lib/providers/theme_provider.dart: This Provider manages the Light and Dark Mode Theme that we have incorporated in for our app.
- lib/providers/undo_redo_provider.dart: This file fulfills our requirement for 'Undo and Redo'. This Provider controls the undo and redo functionality of our app.
- lib/views/add_edit_card_screen.dart: This widget/screen contains the UI of when we add or edit a card. A user can add multiple definitions to a card and an optional hint if they desire. Also pulls from the dictionary API where we fetch a list of definitions that a user can choose from.
- lib/views/add_edit_deck_screen.dart: This widget/screen is for users to fill in a Form that requires a user to put in a name for their Deck and optional description of their deck.
- lib/views/deck_detail_screen.dart: This widget/screen shows the content of a single deck. It contains a list of flashcards within a deck along with a practice button at the top where people can use to practice the flashcards they made. You can also delete or edit existing cards on this screen.
- lib/views/home_screen.dart: This is our main screen of our app where all users start from. Here lies the title of our app, a scrollable list of all decks, two buttons on the top right where users can change the UI language for the app and also toggle on light or dark mode theme. On the bottom, there is a button where users can tap on it and opens up the Add/Edit Deck Screen. Also a undo button appears here when a deck is delete and you want to undo that action.
- lib/views/practice_screen.dart: This widget/screen fulfills our requirement of 'Accessing Phone Sensors' and 'Gesture Detection'. On this screen, this is where users get to practice with the flashcards they have made. If a user shakes their phone, the phone sensors are triggered and shuffles the deck based on this motion. You can also swipe left and right to go back or forward, tap and hold to reveal a hint, and double tapping the screen to skip the current flashcard that a user is on. There is a completion screen at the end once a user goes through all the cards in their deck and prompts then to either restart or go back to their deck.

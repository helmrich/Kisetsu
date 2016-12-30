![AniManager preview on iPhone](https://github.com/helmrich/AniManager/blob/master/images/animanager-iphone-preview.png?raw=true)

AniManager is an application for iOS that lets the user track and explore anime and manga. This app was created as my last project for the [iOS Developer Nanodegree by Udacity](https://www.udacity.com/course/ios-developer-nanodegree--nd003) which is supposed to be an own iOS application. 

The app is written in Swift 3 and uses the [AniList](https://anilist.co) API to get and modify data. As of now the app *requires* an AniList account but it's planned to implement a mode without login that has limited functionality in the future.

Note: This is *not* an official AniList application

## Get Started
1. Download/clone the repository
2. Create a free AniList account [here](https://anilist.co/register)
3. After registering and verifying your account, go to [your account's developer settings](https://anilist.co/settings/developer) and click on the **Create New Client** button
4. Fill in the fields *like so*...

	![](https://github.com/helmrich/AniManager/blob/master/screenshots/anilist-client-creation.png?raw=true)
  
5. The value for ```Client Redirect Uri``` should be ```AniManager://```, the value for ```Name``` should be ```AniManager```
6. Click on **Save**
7. The Client ID and Client Secret text fields should now be filled out automatically
8. Open the project
9. Open the ```AniListConstant``` file in ```Models/Clients/AniList/Constants/```
10. Assign your AniList Client ID and Client Secret to the corresponding constants (**Client ID**: ```clientId```, **Client Secret**: ```clientSecret```) by replacing the placeholders in them
11. Run the app
12. Tap on the **Login with AniList** button and login with your AniList account's username/email and password
13. Tap on **Approve** to authenticate the application and grant it permissions to modify your AniList data on your behalf

## Current Features

### Browsing
Browse Anime and Manga with filters or search them by name.

### Lists
See your AniList account's default lists (custom lists are not supported yet).

### Series Management
Manage your lists' anime and manga (list status, watched episodes, read chapters/volumes, favourites, rating).

### Series Details
See anime/manga series details such as...

- Average rating
- Number of Episodes
- Episode duration
- Characters
- External Links (Crunchyroll, Twitter, Official Homepage, Hulu, Funimation, etc.)
- Trailer
- Genres/Tags
- Description
- Season
- Status
- Type

## Plans for the Future
I'm not 100% sure if or when I'll submit the application to the App Store but there are still quite many things I want to add to or refine in the application before I consider submitting it to the App Store.

**Some of the planned additions/features are**:

- Additional rating systems (currently only ratings from 1 to 10 are available)
- Settings tab (with options to change the rating systems, title language (English, Romaji, Japanese), favourite genres and an option for WiFi-only image downloads)
- Home tab (with sections like "recommended", "new", "current season", etc.)
- Relations to connected series in the series detail
- Actors/Actresses info
- Staff info
- Countdown to new episodes and optional push notifications for new episodes/chapters




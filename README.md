# music-search

Sample iOS App written in Swift that finds songs using iTunes Search API (https://itunes.apple.com/search) and their lyrics using Wikia Lyrics API (http://lyrics.wikia.com/api.php)

___

The requirements are as follows:

#### 1. Landing Screen

+ Search Screen that allows customers to enter a search term.
+ Calls the Apple iTunes API and display all the returned track names, artist name, album name, and image of album in each cell on the Table
+ Clicking a cell should navigate to the lyrics screen.
  
#### 2. Lyrics Screen 

+ Display all the information from the previous cell plus the lyrics returned from the wikia service.
  
Additional Features:
1. Infinite Loading
2. Support for iPhones, iPads and all orientation modes

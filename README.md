`Flutter 2.0.0`

The credentials used for the SDKs are currently exposed so you can test the app directly without doing any setup.

## Login with Facebook or Google
I both added facebook and Google login.
- In order for the same email from facebook and google account to be used in login, I did not integrate the google login with Firebase Auth, only Facebook.
- This is in order to prevent the "Email already exists" error from firebase. Only for development/testing. 

<hr> 

## Map with user location and route to a random place
**I hit a roadblock with my google cloud account. I wasn't able to activate it using a prepaid card from my bank. Because of this:**
- Drawing polylines to show routes wasn't possible without Google Directions API.
- It is not correct to just generate random long-lat positions because not all geographic points have valid routes recognizable by any maps api.
- So the only solution is to pick random "valid" place within radius (10 KM).
- Google Places API offers the `nearbysearch` endpoint which really fits this function. But I used LocationIQ instead because of billing activation issue.
- I wasn't able to find alternate solutions for calculating polylines aside from Google Directions API.
- Polylines is used to draw the "turn-by-turn" navigation described in the assessment instruction.

I created an alternate solution by **opening up an external Maps** app to show the routes of the random place or location.

<hr> 

## Browse and read Newsfeed
This one was quite easy.
- I fetched the rss feed from BBC News: http://feeds.bbci.co.uk/news/world/rss.xml
- Used the dart plugin `webfeed` to parse it.
- Used ListView to display the list and `url_launcher` plugin to open up the news article.

<hr> 


## MDAS Calculator with parenthesis
I encountered a kind of "small" problem with this. This is the example from the assessment instruction:
- (e.g. 7+2(4-2)/2 = 9 )
- The problem was inputting `7+2(4-2)/2` into the calculator I made returns Syntax Error
- Inputting `7+2*(4-2)/2` did the job and return the correct result.
- Basic calculations seem to work fine.




### Sample output

https://user-images.githubusercontent.com/37391380/125145909-0313d300-e156-11eb-8606-0fa9b67b25d4.mp4

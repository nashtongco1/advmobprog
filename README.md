# Laboratory Activity 5

## Laboratory Discussion

### 1. DummyJSON and Firebase Workflow from Sign In to Sign Up

The application supports two authentication methods: DummyJSON and Firebase Authentication.

For DummyJSON, the user enters a username and password on the Sign In screen. The application sends the credentials to the DummyJSON authentication API through the UserService. If the credentials are valid, the returned user information and access token are saved locally using SharedPreferences. The user is then redirected to the main application.

For Firebase, the user can sign in using an email address and password. The credentials are passed to Firebase Authentication through the UserService. After a successful login, the Firebase user information and the application's stored user information are saved locally so that the application can identify the currently logged-in user.

If the user does not have a Firebase account, the user can proceed to the Sign Up screen. The user provides the required information such as first name, last name, age, contact number, username, email address, and password. The password is validated before the account is created. After successful registration, the Firebase account is created and the user's information is stored for use in the Profile screen.

The application also stores the login type so that it can determine whether the current user logged in through DummyJSON or Firebase. This allows the Profile screen to display the appropriate information and account management options.

### 2. Main Idea Behind UserService

The main idea behind UserService is to separate user authentication and account management logic from the user interface.

Instead of placing authentication code directly inside the Sign In, Sign Up, Profile, and Settings screens, these screens call methods from UserService. UserService is responsible for operations such as signing in, creating an account, saving user information, retrieving user information, updating the Firebase username, changing the Firebase password, deleting a Firebase account, and logging out.

This makes the application easier to organize because the screens mainly handle the user interface while UserService handles authentication and user-related operations.

UserService also handles both DummyJSON and Firebase users. The stored login type allows the service and the application to determine which authentication method is being used.

### 3. Benefits of Firebase in the Flutter Application

Firebase Authentication provides a convenient way to implement user authentication in a Flutter application. It handles important authentication processes such as account creation, email and password login, password updates, user reauthentication, and account deletion.

Using Firebase also reduces the amount of authentication logic that needs to be created manually. Firebase manages user credentials and provides authentication methods that can be accessed directly from Flutter.

In this activity, Firebase allows the application to provide account management features that are not available to the DummyJSON user. Firebase users can create their own accounts, update their username, change their password, and permanently delete their account.

Firebase also works together with the application's UserService and local storage. This allows the application to keep authentication logic organized while still storing the information needed to display the user's profile and determine the user's login type.

### 4. Logout

The Logout option is located in the Settings screen. When the user logs out, the application clears the locally stored user session and authentication information and returns the user to the Sign In screen.

This logout process works for both DummyJSON and Firebase users. Clearing the saved session prevents the previous user's information from remaining active after logout.
## Certificate API

The request to generate a certificate would be:

    POST /datasets

Updating a certificate would follow the current url structure of:

    POST /datasets/:d_id/certificates

### Authentication

`:token_authenticatable` has been deprecated in devise (our authentication library).  Though it's quite straightforward to include with [this gist](https://gist.github.com/josevalim/fb706b1e933ef01e4fb6#file-2_safe_token_authentication-rb)

On the user account page, we could have a "generate API key" method which would create and display a key.

A user may be submitting on another users behalf, in this case they could supply a target email and we could use the dataset transfer functionality to transfer and notify a particular email address.

### Format

The JSON representation of a certificate is structured like this:

```js
{
  version: 0.1,
  licence: "http://opendatacommons.org/licenses/odbl/",
  certificate: {
    title: "Open Data Certificate for …",
    uri: "https://…",
    jurisdiction: ''
    // ...
    dataset: {

      /* Inferred from responses */
      title: "…",
      publisher: "…",
      uri: "…",
      dataLicense: "…",
      contentLicense: "…",

      /* Questionnaire responses */
      dataTitle: "the dataset",
      // ...

    }
  }
}
```

Some of the content in the response wouldn't be able to be set by the api (as they are generated by the responses given), so I think the populate request should look something like this:

```js
{
  jurisdiction: 'US',
  user_email: 'user@example.com',
  dataset:{
    dataTitle: 'Some dataset',
    documentationUrl: 'http://…',
    releaseType: 'oneoff',
    // ...
  }
}
```

### Implementation Approach

This could be implemented a CertificateGenerator model, which stores details of the request and attempts to create the certificate/dataset.  We could use this to work out which certificates have been generated via the api down the line.

There are a few different response types that need to be catered for, each should match the certificate json.

* Text field - `"title": "the data title"`
* Radio buttons - `"releaseType": "oneoff"` ('oneoff' must be an answer)
* Multiple choice - `"releaseType": ["oneoff", "series"]` ('oneoff' & 'series' must be answers)

Surveyor repeating sections are potentially more complex, though within the ODC it's only ever a repeating text field so we could just use:

* Repeating section - `"listing": ["one", "two", "three"]`

### Potential issues

#### Autofill

When someone enters a data.gov.uk address as a documentation url, a lot of the responses can be automatically filled out.  The questions are filled out and saved from the client side code, so it may take some effort to also implement this on the server side.

This would have an impact on the certificate page where you are notified if answers don't match the data-kitten response.
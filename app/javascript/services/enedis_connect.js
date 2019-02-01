// Créer une const userId pour récupérer ça dans le HTML
const userId = document.querySelector("#consent").dataset.userid;
const clientId = document.querySelector("#consent").dataset.cliid;
// console.log(process.env.ENEDIS_CLIENT_ID);
const clientSecret = document.querySelector("#consent").dataset.clisecret;

// Utilisation d'un proxy pour contourner probleme :
  // "No 'Access-Control-Allow-Origin' header is present
  // on the requested resource—when trying to get data from
  // a REST API
const proxyurl = "https://cors-anywhere.herokuapp.com/";

// En attendant de les récupérer directement par une requête :
  const usagePointId0 = "22516914714270";
  const usagePointId = usagePointId0;
  const code = "THd5DVk1q9Sr3c2qWpFlxdHGoP1P89";

// *** FUNCTIONS ***

const consentCall = () => {
  const link = 'https://gw.hml.api.enedis.fr/group/espace-particuliers/consentement-linky/oauth2/authorize?client_id=3d5cbbbb-fcf4-4c6a-8c86-f18a5ba156e9&state=fz80ac780&duration=P6M&response_type=code&redirect_uri=https://gw.hml.api.enedis.fr/redirect';
  console.log("1 - Demande de consentement (client_id, state) --> code, usage_point_id");
  console.log("... Capter 'code' dans une variable");
  //   fetch(link)
  //       // .then(response => console.log(response))
  //       .then(response => response.text())

  //       // .then(function(response){
  //         // console.log(response);
  //       // });

  //       // .then((data) => {
  //       //   // Do something with the response
  //       //   parser = new DOMParser();
  //       //   doc = parser.parseFromString(data, "text/html");
  //       //   console.log(doc.body);
  //       //   const script = doc.querySelector("script");
  //       //   console.log(script);
  //       //   // parseQueryString();
  //       //   // console.log(parmas);
  //       // });

}

const addHousingToUser = (usagePointId) => {
  console.log("2 - Créer un logement (Housing.new, Housing.save) et l'associer au User");
  console.log("... Enregistrer enedis_usage_point_id");
  fetch('/housings/', {
    method: 'POST',
    body: JSON.stringify({enedis_usage_point_id: usagePointId}),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': Rails.csrfToken()
    },
    credentials: 'same-origin'
  }).then(function(response) {
    return response.json();
  }).then(function(data) {
    console.log(data);
  });
}

const getCustomerTokens = (code, clientId, clientSecret) => {
  console.log("3 - Obtention jetons client (code, client_id_, client_secret) --> acces_token, refresh_token");
  console.log("... Enregstrer access_token + refresh_token dans DB.users");

  console.log(`code : ${code}`);
  console.log(`client_id : ${clientId}`);
  console.log(`clientSecret : ${clientSecret}`);



  fetch(proxyurl + "https://gw.hml.api.enedis.fr/v1/oauth2/token?redirect_uri=https://gw.hml.api.enedis.fr/redirect", {
    method: "post",
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      // 'Access-Control-Allow-Origin': '*',
      // 'Access-Control-Allow-Headers': 'Content-Type',
      // 'Access-Control-Allow-Credentials': 'true'
    },

    //make sure to serialize your JSON body
    body: JSON.stringify({
      code: code,
      client_id: clientId,
      client_secret: clientSecret,
      // grand_type: authorization_code
    })
  })
  .then( (response) => {
     //do something awesome that makes the world a better place
     console.log(response);
  });


//*** ex Ou, si on veut généraliser la requête POST : **
  // var url = 'https://example.com/profile';
  // var data = {username: 'example'};

  // fetch(url, {
  //   method: 'POST', // or 'PUT'
  //   body: JSON.stringify(data), // data can be `string` or {object}!
  //   headers:{
  //     'Content-Type': 'application/json'
  //   }
  // }).then(res => res.json())
  // .then(response => console.log('Success:', JSON.stringify(response)))
  // .catch(error => console.error('Error:', error));
//ex ***

  //   fetch(link)
  //       // .then(response => console.log(response))
  //       .then(response => response.text())

  //       // .then(function(response){
  //         // console.log(response);
  //       // });

  //       // .then((data) => {
  //       //   // Do something with the response
  //       //   parser = new DOMParser();
  //       //   doc = parser.parseFromString(data, "text/html");
  //       //   console.log(doc.body);
  //       //   const script = doc.querySelector("script");
  //       //   console.log(script);
  //       //   // parseQueryString();
  //       //   // console.log(parmas);
  //       // });
}


const refreshTokens = (refreshToken, clientId, clientSecret) => {
  console.log("4 - Renouvellement jetons client (refresh_token, client_id_, client_secret) --> acces_token, refresh_token");
  console.log("... Enregistrer access_token + refresh_token dans DB.users");

  fetch("https://gw.hml.api.enedis.fr/v1/oauth2/token?redirect_uri=https://gw.hml.api.enedis.fr/redirect", {
    method: "POST",
    // dataType: 'jsonp',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      // 'Access-Control-Allow-Origin': '*',
      // 'Access-Control-Allow-Headers': 'Content-Type',
      // 'Access-Control-Allow-Credentials': 'true'
    },

    //make sure to serialize your JSON body
    body: JSON.stringify({
      refresh_token: refreshToken,
      client_id: clientId,
      client_secret: clientSecret,
      // grand_type: refresh_token
    })
  })
  .then( (response) => {
     //do something awesome that makes the world a better place
     console.log(response);
  });
}
// *** END FUNCTIONS ***


// ** LIAISON ENEDIS ** :
const enedisLink = () => {
  console.log("Appel de consentement à faire");
  const enedis_connect = document.getElementById('enedis-btn')
  if (enedis_connect) {
    enedis_connect.addEventListener('click', function(event) {
      event.preventDefault(); // pour empécher de recharger la page
      const state = `${userId - 1}` // en attendant mieux... et pour Clients test ENEDIS
      // consentCall();
      // addHousingToUser(usagePointId);
      // getCustomerTokens(code, clientId, clientSecret);

      //Test :
      const refreshToken = "fUTh2rDVQimqjpwbuIcx84v8OGEO6l1nrUMBHbJpv5RxcR";
      refreshTokens(refreshToken, clientId, clientSecret);
    });
  };
};

export { enedisLink };

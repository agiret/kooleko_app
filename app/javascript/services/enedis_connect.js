// Créer une const userId pour récupérer ça dans le HTML
const userId = document.querySelector("#consent").dataset.userid;
const clientId = document.querySelector("#consent").dataset.cliid;

// En attendant de les récupérer directement par une requête :
const usagePointId0 = "12345";
let usagePointId = usagePointId0;

// Créer une fonction saveUsagePointId(element) pour enregistrer réponse appel
    // requête AJAX en POST avec fetch

const saveUsagePointId = (element) => {
    date = element.dataset.dt;
    fetch(`/flats/${flatId}/availabilities/`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      'X-CSRF-Token': Rails.csrfToken()
    },
    credentials: 'same-origin',
    body: JSON.stringify({ availability: {start_time: date} })
  })
    .then(response => response.json())
    .then((data) => {
      updateAvailabilityHtml(element, true, data.id);
    });
}

const addHousingToUser = (userId, usagePointId) => {
  console.log("0 - Créer un logement (Housing.new, Housing.save) et l'associer au User");
}


const consentCall = () => {
  console.log("Appel de consentement à faire");
  // ** APPEL DE CONSENTEMENT ** :

  // Associer "state" = identifiant du client dans notre DB
  // (avec dernier chiffre = numéro du client test enedis)
      // ramener l'id du current_user
  // Requête :
  // Comment envoyer une variable d'environnement au JS ??
  // console.log(process.env.ENEDIS_CLIENT_ID);
  const link = 'https://gw.hml.api.enedis.fr/group/espace-particuliers/consentement-linky/oauth2/authorize?client_id=3d5cbbbb-fcf4-4c6a-8c86-f18a5ba156e9&state=fz80ac780&duration=P6M&response_type=code&redirect_uri=https://gw.hml.api.enedis.fr/redirect';
    // essayer de juste lancer l'url > récupérer les params
    // et revenir avec les données qu'il faut...
  const enedis_connect = document.getElementById('enedis-btn')
  if (enedis_connect) {
    enedis_connect.addEventListener('click', function(event) {
      event.preventDefault(); // pour empécher de recharger la page
      const state = `${userId - 1}`
      addHousingToUser(userId, usagePointId);
      console.log("1 - Demande de consentement (client_id, state) --> code, usage_point_id");
      console.log("... Capter 'code' dans une variable");
      console.log("... Enregistrer usage_point_id dans DB.housings");
      // Appeler une fonction "saveUsagePointId"
      console.log("2 - Obtention jetons client (code, client_id_, client_secret) --> acces_token, refresh_token");
      console.log("... Enregstrer access_token + refresh_token dans DB.users");

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
    });
  };
}

export { consentCall };

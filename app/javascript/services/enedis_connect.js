// Créer une const userId pour récupérer ça dans le HTML
const userId = document.querySelector("#consent").dataset.userid;
const clientId = document.querySelector("#consent").dataset.cliid;
// console.log(process.env.ENEDIS_CLIENT_ID);


// En attendant de les récupérer directement par une requête :
const usagePointId0 = "12345";
let usagePointId = usagePointId0;

// *** FUNCTIONS ***

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

const consentCall = () => {
  const link = 'https://gw.hml.api.enedis.fr/group/espace-particuliers/consentement-linky/oauth2/authorize?client_id=3d5cbbbb-fcf4-4c6a-8c86-f18a5ba156e9&state=fz80ac780&duration=P6M&response_type=code&redirect_uri=https://gw.hml.api.enedis.fr/redirect';
  console.log("1 - Demande de consentement (client_id, state) --> code, usage_point_id");
  console.log("... Capter 'code' dans une variable");

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
      consentCall();
      addHousingToUser(usagePointId);
      console.log("3 - Obtention jetons client (code, client_id_, client_secret) --> acces_token, refresh_token");
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

export { enedisLink };

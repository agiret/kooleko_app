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
      console.log("Hello de enedis_connect !");

      fetch(link)
          // .then(response => console.log(response))
          .then(response => response.text())

          // .then(function(response){
            // console.log(response);
          // });

          // .then((data) => {
          //   // Do something with the response
          //   parser = new DOMParser();
          //   doc = parser.parseFromString(data, "text/html");
          //   console.log(doc.body);
          //   const script = doc.querySelector("script");
          //   console.log(script);
          //   // parseQueryString();
          //   // console.log(parmas);
          // });
    });
  };
}

export { consentCall };

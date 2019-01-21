const link = 'https://gw.hml.api.enedis.fr/group/espace-particuliers/consentement-linky/oauth2/authorize?client_id=3d5cbbbb-fcf4-4c6a-8c86-f18a5ba156e9&state=fz80ac780&duration=P6M&response_type=code&redirect_uri=https://gw.hml.api.enedis.fr/redirect'

const enedis_connect = document.getElementById('enedis-btn')
if (enedis_connect) {
  enedis_connect.addEventListener('click', function(event) {
    event.preventDefault();
    console.log("Hello de enedis_connect !");
    fetch(link)
        // .then(response => console.log(response))
        .then(response => response.text())
        .then((data) => {
          // Do something with the response
          console.log(data);
        });
  });
}

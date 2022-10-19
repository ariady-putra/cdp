export function validateInput(input, regex, error, setError) {
  setError(input.match(regex) ? '' : error);
}

export async function apiCall(name, url, callback) {
  const fetchAPI = await fetch(url + '&json=1');
  const toJSON = await fetchAPI.json();
  try {
    callback({title:name,...toJSON});
  }
  catch {
    console.log(toJSON);
  }
}

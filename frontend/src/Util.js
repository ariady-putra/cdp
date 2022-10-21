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
  finally {
    window.scrollTo(0,0);
  }
}

export function toggleForm(name, form, sub) {
  switch(form.current.style.display)
  {
    case 'none':
      form.current.style.display = 'block';
      sub.target.innerText = `▾ ${name}`;
      break;
      
    case 'block':
      form.current.style.display = 'none';
      sub.target.innerText = `▸ ${name}`;
      break;
      
    default:
      break;
  }
}

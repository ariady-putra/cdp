import React from 'react';
import {
  apiCall,
  toggleForm,
} from '../../Util';

function Transfer({output}) {
  const name = 'Transaction build';
  const form = React.useRef();
  const walletNameSrc = React.useRef();
  const walletNameDst = React.useRef();
  const lovelaces = React.useRef();
  
  return (
    <div>
      <sub onClick={sub => toggleForm(name, form, sub)}>▸ {name}</sub>
      
      <form style={{display:'none'}} ref={form} onSubmit={tx => {
        tx.preventDefault();
        apiCall(name, `/transfer?lovelaces=${lovelaces.current.value}`+
          `&walletNameSrc=${walletNameSrc.current.value}`+
          `&walletNameDst=${walletNameDst.current.value}`,
          output);
      }}>
        
        <input type='text' id='walletNameSrc' name='walletNameSrc'
          placeholder='Enter src wallet name'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameSrc}
          required
        />
        
        <input type='text' id='walletNameDst' name='walletNameDst'
          placeholder='Enter dst wallet name or address'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameDst}
          required
        />
        
        <input type='number' id='lovelaces' name='lovelaces'
          placeholder='Lovelaces'
          min={1000000}
          ref={lovelaces}
          required
        />
        
        <button type='submit'>
          Send Tx
        </button>
        
      </form>
    </div>
  );
}

export default Transfer;

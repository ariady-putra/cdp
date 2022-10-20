import React from 'react';
import {
  apiCall,
  toggleForm,
} from '../../Util';

function TransferAtomicSwap({output}) {
  const name = 'Transfer atomic-swap';
  const form = React.useRef();
  const walletName1 = React.useRef();
  const walletName2 = React.useRef();
  const lovelaces1 = React.useRef();
  const lovelaces2 = React.useRef();
  
  return (
    <div>
      <sub onClick={sub => toggleForm(name, form, sub)}>▸ {name}</sub>
      
      <form style={{display:'none'}} ref={form} onSubmit={tx => {
        tx.preventDefault();
        apiCall(name, `/transferAtomicSwap?`+
          `&walletName1=${walletName1.current.value}`+
          `&walletName2=${walletName2.current.value}`+
          `&lovelaces1=${lovelaces1.current.value}`+
          `&lovelaces2=${lovelaces2.current.value}`,
          output);
      }}>
        
        <input type='text' id='walletName1' name='walletName1'
          placeholder='Enter wallet name 1'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletName1}
          required
        />
        
        <input type='number' id='lovelaces1' name='lovelaces1'
          placeholder='Lovelaces 1'
          min={1000000}
          ref={lovelaces1}
          required
        />
        
        <input type='text' id='walletName2' name='walletName2'
          placeholder='Enter wallet name 2'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletName2}
          required
        />
        
        <input type='number' id='lovelaces2' name='lovelaces2'
          placeholder='Lovelaces 2'
          min={1000000}
          ref={lovelaces2}
          required
        />
        
        <button type='submit'>
          Send Tx
        </button>
        
      </form>
    </div>
  );
}

export default TransferAtomicSwap;

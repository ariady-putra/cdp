import React from 'react';
import {
  apiCall,
  toggleForm,
} from '../../Util';

function TransferMultiWitness({output}) {
  const name = 'Transfer multiwitness';
  const form = React.useRef();
  const walletNameSrc1 = React.useRef();
  const walletNameSrc2 = React.useRef();
  const walletNameDst = React.useRef();
  const walletNameChg = React.useRef();
  const lovelaces = React.useRef();
  
  return (
    <div>
      <sub onClick={sub => toggleForm(name, form, sub)}>▸ {name}</sub>
      
      <form style={{display:'none'}} ref={form} onSubmit={tx => {
        tx.preventDefault();
        apiCall(name, `/transferMultiwitness?lovelaces=${lovelaces.current.value}`+
          `&walletNameSrc1=${walletNameSrc1.current.value}`+
          `&walletNameSrc2=${walletNameSrc2.current.value}`+
          `&walletNameDst=${walletNameDst.current.value}`+
          `&walletNameChg=${walletNameChg.current.value}`,
          output);
      }}>
        
        <input type='text' id='walletNameSrc1' name='walletNameSrc1'
          placeholder='Enter src wallet name 1'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameSrc1}
          required
        />
        
        <input type='text' id='walletNameSrc2' name='walletNameSrc2'
          placeholder='Enter src wallet name 2'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameSrc2}
          required
        />
        
        <input type='text' id='walletNameDst' name='walletNameDst'
          placeholder='Enter dst wallet name or address'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameDst}
          required
        />
        
        <input type='text' id='walletNameChg' name='walletNameChg'
          placeholder='Enter chg wallet name or address'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameChg}
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

export default TransferMultiWitness;

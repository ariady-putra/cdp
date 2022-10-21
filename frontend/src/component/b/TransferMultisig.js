import React from 'react';
import {
  apiCall,
  toggleForm,
} from '../../Util';

function TransferMultisig({output}) {
  const name = 'Send MULTISIG Tx';
  const form = React.useRef();
  const walletNameMultisig = React.useRef();
  const walletNameDst = React.useRef();
  const witness1 = React.useRef();
  const witness2 = React.useRef();
  const witness3 = React.useRef();
  const minutes = React.useRef();
  const lovelaces = React.useRef();
  
  return (
    <div>
      <sub onClick={sub => toggleForm(name, form, sub)}>▸ {name}</sub>
      
      <form ref={form} style={{display:'none'}} onSubmit={tx => {
        tx.preventDefault();
        apiCall('Transfer MULTISIG',
          `/transferMultisig?lovelaces=${lovelaces.current.value}`+
          `&walletNameMultisig=${walletNameMultisig.current.value}`+
          `&walletNameDst=${walletNameDst.current.value}`+
          `&witness1=${witness1.current.value}`+
          `&witness2=${witness2.current.value}`+
          `&witness3=${witness3.current.value}`+
          `&minutes=${minutes.current.value}`,
          output);
      }}>
        
        <input type='text' id='walletNameMultisig' name='walletNameMultisig'
          placeholder='Enter MULTISIG wallet name'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameMultisig}
          required
        />
        
        <input type='text' id='witness1' name='witness1'
          placeholder='Witness 1'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={witness1}
          required
        />
        
        <input type='text' id='witness2' name='witness2'
          placeholder='Witness 2'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={witness2}
          required
        />
        
        <input type='text' id='witness3' name='witness3'
          placeholder='Witness 3'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={witness3}
          required
        />
        
        <input type='text' id='walletNameDst' name='walletNameDst'
          placeholder='Enter dst wallet name or address'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletNameDst}
          required
        />
        
        <input type='number' id='minutes' name='minutes'
          placeholder='Valid for how many minutes'
          min={1}
          ref={minutes}
          required
        />
        
        <input type='number' id='lovelaces' name='lovelaces'
          placeholder='Lovelaces'
          min={1000000}
          ref={lovelaces}
          required
        />
        
        <button type='submit'>{name}</button>
      </form>
    </div>
  );
}

export default TransferMultisig;

import React from 'react';
import {
  apiCall,
  toggleForm,
} from '../../Util';

function CreateMultisigWallet({output}) {
  const name = 'Create MULTISIG Wallet';
  const form = React.useRef();
  const walletName1 = React.useRef();
  const walletName2 = React.useRef();
  const walletName3 = React.useRef();
  const minutes = React.useRef();
  
  return (
    <div>
      <sub onClick={sub => toggleForm(name, form, sub)}>▸ {name}</sub>
      
      <form ref={form} style={{display:'none'}} onSubmit={tx => {
        tx.preventDefault();
        apiCall(name,`/createMultisigWallet?minutes=${minutes.current.value}`+
          `&walletName1=${walletName1.current.value}`+
          `&walletName2=${walletName2.current.value}`+
          `&walletName3=${walletName3.current.value}`,
          output);
      }}>
        
        <input type='text' id='walletName1' name='walletName1'
          placeholder='Enter wallet name 1'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletName1}
          required
        />
        
        <input type='text' id='walletName2' name='walletName2'
          placeholder='Enter wallet name 2'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletName2}
          required
        />
        
        <input type='text' id='walletName3' name='walletName3'
          placeholder='Enter wallet name 3'
          title='Alphanumeric and underscore only.'
          pattern='[0-9A-Za-z_]+'
          ref={walletName3}
          required
        />
        
        <input type='number' id='minutes' name='minutes'
          placeholder='Valid AFTER how many minutes'
          min={1}
          ref={minutes}
          required
        />
        
        <button type='submit'>{name}</button>
      </form>
    </div>
  );
}

export default CreateMultisigWallet;

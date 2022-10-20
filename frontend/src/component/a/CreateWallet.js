import React from 'react';
import { apiCall } from '../../Util';

function CreateWallet({output}) {
  const walletName = React.useRef();
  
  return (
    <form onSubmit={tx => {
      tx.preventDefault();
      apiCall('Create Wallet', `/createWallet?walletName=${walletName}`,
        output);
    }}>
      
      <input type='text' id='walletName' name='walletName'
        placeholder='Enter wallet name'
        title='Alphanumeric and underscore only.'
        pattern='[0-9A-Za-z_]+'
        ref={walletName}
        required
      />
      
      <button type='submit'>
        Create Wallet
      </button>
      
    </form>
  );
}

export default CreateWallet;

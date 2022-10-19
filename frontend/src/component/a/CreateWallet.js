import React from 'react';
import {
  apiCall,
  validateInput,
} from '../../Util';

function CreateWallet({output}) {
  const [walletName, setWalletName] = React.useState(() => '');
  const [error, setError] = React.useState(() => '');
  
  return (
    <table><tbody><tr>
      
      <td><input type='text' id='walletName' name='walletName'
        placeholder='Enter wallet name'
        value={walletName} onChange={wallet => {
          setWalletName(wallet.target.value);
          validateInput(wallet.target.value,
            /^[0-9A-Za-z_]+$/i, 'Alphanumeric and underscore only.',
            setError);
        }}
      /></td>
      
      <td><button disabled={!walletName.length || error}
        onClick={() => apiCall('Create Wallet',
          `/createWallet?walletName=${walletName}`,
          output)}>Create Wallet
      </button></td>
      
      <td><div className='Error'>
        {error}
      </div></td>
      
    </tr></tbody></table>
  );
}

export default CreateWallet;

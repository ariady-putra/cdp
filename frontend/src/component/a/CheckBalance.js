import React from 'react';
import {
  apiCall,
  validateInput,
} from '../../Util';

function CheckBalance({output}) {
  const [walletName, setWalletName] = React.useState(() => '');
  const [error, setError] = React.useState(() => '');
  
  function submit() {
    apiCall('Check Balance',
      `/checkBalance?wallet=${walletName}`,
      output);
  }
  
  return (
    <table><tbody><tr>
      
      <td><input type='text' id='wallet' name='wallet'
        placeholder='Enter wallet name or address'
        value={walletName} onChange={wallet => {
          setWalletName(wallet.target.value);
          validateInput(wallet.target.value,
            /^[0-9A-Za-z_]+$/i, 'Alphanumeric and underscore only.',
            setError);
        }}
        onKeyUp={key => {
          if(key.code === 'Enter')
            submit();
        }}
      /></td>
      
      <td><button disabled={!walletName.length || error}
        onClick={submit}>Check Balance
      </button></td>
      
      <td><div className='Error'>
        {error}
      </div></td>
      
    </tr></tbody></table>
  );
}

export default CheckBalance;

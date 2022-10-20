import React from 'react';
import { apiCall } from '../../Util';

function CheckBalance({output}) {
  const walletName = React.useRef();
  
  return (
    <form onSubmit={tx => {
      tx.preventDefault();
      apiCall('Check Balance', `/checkBalance?wallet=${walletName.current.value}`,
        output);
    }}>
      
      <input type='text' id='wallet' name='wallet'
        placeholder='Enter wallet name or address'
        title='Alphanumeric and underscore only.'
        pattern='[0-9A-Za-z_]+'
        ref={walletName}
        required
      />
      
      <button type='submit'>
        Check Balance
      </button>
      
    </form>
  );
}

export default CheckBalance;

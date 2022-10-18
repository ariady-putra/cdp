import React from 'react';

function CreateWallet({output}) {
  const [walletName, setWalletName] = React.useState(() => '');
  const [error, setError] = React.useState(() => '');
  
  function validateInput(input) {
    setError(input.match(/^[0-9A-Za-z_]+$/i) ?
      '' : 'Alphanumeric and underscore only.');
  }
  
  async function createWallet() {
    const walletCreation = await fetch(`/createWallet?json=1&walletName=${walletName}`);
    const walletJSON = await walletCreation.json();
    try {
      output({title:'Create Wallet',...walletJSON});
    }
    catch {
      console.log(walletJSON);
    }
  }
  
  return (
    <table><tbody><tr>
      
      <td><input type='text'
        placeholder='Enter wallet name'
        value={walletName}
        onChange={wallet => {
          setWalletName(wallet.target.value);
          validateInput(wallet.target.value);
        }}
      /></td>
      
      <td><button disabled={walletName.length === 0 || error}
        onClick={() => createWallet()}>Create Wallet
      </button></td>
      
      <td><div className='Error'>
        {error}
      </div></td>
      
    </tr></tbody></table>
  );
}

export default CreateWallet;

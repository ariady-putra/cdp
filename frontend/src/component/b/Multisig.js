import React from 'react';
import { toggleForm } from '../../Util';
import CreateMultisigWallet from './CreateMultisigWallet';
import TransferMultisig from './TransferMultisig';

function Multisig({output}) {
  const group = 'Multisig';
  const forms = React.useRef();
  
  return (
    <div>
      <div onClick={title => toggleForm(group, forms, title)}
        className='subTitle'>▸ {group}</div>
      
      <div ref={forms} style={{display:'none'}}>
        <CreateMultisigWallet output={output}/>
        <TransferMultisig output={output}/>
      </div>
    </div>
  );
}

export default Multisig;

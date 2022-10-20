import './App.css';
import React from 'react';
import CreateWallet from './component/a/CreateWallet';
import CheckBalance from './component/a/CheckBalance';
import Transfer from './component/a/Transfer';
import TransferBuildRaw from './component/a/TransferBuildRaw';
import TransferMultiWitness from './component/a/TransferMultiwitness';
import TransferAtomicSwap from './component/a/TransferAtomicSwap';

function App() {
  const [result, setResult] = React.useState();
  
  return (
    <div className='App'>
      <h1>Cardano Tools</h1>
      
      <div style={{display: result ?
        'none' : 'block'}}>
        <CreateWallet output={setResult}/>
        <CheckBalance output={setResult}/>
        <Transfer output={setResult}/>
        <TransferBuildRaw output={setResult}/>
        <TransferMultiWitness output={setResult}/>
        <TransferAtomicSwap output={setResult}/>
      </div>
      
      {result && <div>
        <u>{result.title}</u>
        {result.output && <pre className='ResultOutput'>
          {result.output}
        </pre>}
        {result.error && <pre className='Exception'>
          {result.error}
        </pre>}
        {result.exception && <pre className='Exception'>
          {result.exception}
        </pre>}
        <button onClick={() => setResult()}
          style={{width:'min-content'}}>Back
        </button>
      </div>}
    </div>
  );
}

export default App;

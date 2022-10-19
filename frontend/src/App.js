import './App.css';
import React from 'react';
import CreateWallet from './component/a/CreateWallet';
import CheckBalance from './component/a/CheckBalance';

function App() {
  const [result, setResult] = React.useState();
  
  return (
    <div className='App'>
      <h1>Cardano Tools:</h1>
      {result ? <div>
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
      </div>
      :
      <div>
        <CreateWallet output={setResult}/>
        <CheckBalance output={setResult}/>
      </div>}
    </div>
  );
}

export default App;

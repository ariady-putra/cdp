import React from 'react';
import CreateWallet from './component/a/CreateWallet';

import './App.css';

function App() {
  const [result, setResult] = React.useState();
  
  return (
    <div className='App'>
      <h1>Cardano Tools:</h1>
      {result ? <div>
        <u>{result.title}</u>
        <pre>{result.output}</pre>
        <button onClick={() => setResult()}
          style={{width:'min-content'}}
          >Back
        </button>
      </div>
      :
      <div>
        <CreateWallet output={setResult}/>
      </div>}
    </div>
  );
}

export default App;

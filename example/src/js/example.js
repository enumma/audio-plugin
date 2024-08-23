import { AudioPlugin } from 'enumma-audio-plugin';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    AudioPlugin.echo({ value: inputValue })
}

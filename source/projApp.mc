import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.Sensor as Sensor;
using Toybox.Timer as Timer;

var phoneMethod;
var crashOnMessage = false;
var dataTimer;
var info;
const SAMPLE_PERIOD = 5000; //ms
class projApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        //Comm.registerForPhoneAppMessages(method(:onPhone));
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new projView()] as Array<Views or InputDelegates>;
    }

     function onPhone(msg) as Void {
        // var i;

        // if (crashOnMessage == true && msg.data.equals("Hi")) {
        //     // foo = bar;
        // }

        // for (i = (stringsSize - 1); i > 0; i -= 1) {
        //     strings[i] = strings[i - 1];
        // }
        // strings[0] = msg.data.toString();
        // page = 1;

        WatchUi.requestUpdate();
    }

    function timerCallback() as Void {

        info = Sensor.getInfo();

        // var listener = new projDelegate();
        // Comm.transmit(info.accel, null, null);

    }

    // function onBackgroundData() {
    //     var myData = {
    //         "heartRate": 75, // replace with your actual data
    //         "steps": 1200,   // replace with your actual data
    //         "calories": 450, // replace with your actual data
    //         // add other data you want to send as needed
    //     };
    //     App.write("myDataFile", Lang.toJSON(myData));
    // }

}

function getApp() as projApp {
    return Application.getApp() as projApp;
}
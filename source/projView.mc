import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.System;
import Toybox.Communications;

class projView extends WatchUi.View {

    var label;
    var stepsLabel;
    var heartRate = 0;
    var steps = 0;
    var respirationRate = 0;
    var activeMinutesDay = 0;
    var calories = 0;
    var respiration = 0;
    var updateTimer = null;

    var _heartRateLabel;
    var _stepsLabel;
    var _activeLabel;
    var _caloriesLabel;
    var _respirationLabel;

    function initialize() {
        
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _heartRateLabel = findDrawableById("heartRateLabel");
        _stepsLabel = findDrawableById("stepsLabel");
        _activeLabel = findDrawableById("activeLabel");
        _caloriesLabel = findDrawableById("caloriesLabel");
        _respirationLabel = findDrawableById("respirationLabel");
    }

    function onShow() as Void {
       if(updateTimer == null) {
            var myTimer = new Timer.Timer();
            myTimer.start(method(:fetchHeartRateData), 500, true);
        }
    }
    
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onHide() as Void {
        if (updateTimer != null) {
            updateTimer.stop();
            updateTimer = null;
        }
    }

    function fetchHeartRateData() as Void {
        var hrIterator = ActivityMonitor.getHeartRateHistory(null, false);
        var previous = hrIterator.next();                                   
        var lastSampleTime = null;                                          
        var sample = hrIterator.next();

        if (null != sample) {                                           
            if (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE   
                && previous.heartRate
                != ActivityMonitor.INVALID_HR_SAMPLE) {
                    lastSampleTime = sample.when;
                    heartRate = previous.heartRate;
                    System.println("Previous: " + previous.heartRate);  
                    System.println("Sample: " + sample.heartRate);      
                    System.println("LAST SAMPLE:" + lastSampleTime);
        }
    }
        var info = ActivityMonitor.getInfo();
        steps = info.steps;
        respirationRate = info.respirationRate;
        calories = info.calories;
        respiration = info.respirationRate;

        updateHeartRateValue(heartRate);
        updateStepsValue(steps);
        updateCaloriesMinutesValue(calories);
        updateRespirationMinutesValue(respiration);
        var dataToSend = {
            "heartRate" => heartRate,
            "calories"=>calories
        };

        var listener = new CommListener();
        Communications.transmit(dataToSend, null, listener);
    }

    function updateHeartRateValue(heartRate as Number) as Void {
         _heartRateLabel.setText("Heart rate:" + heartRate.toString());
         WatchUi.requestUpdate();
    }

    function updateStepsValue(steps as Number) as Void {
        _stepsLabel.setText("Steps:" + steps.toString());

        WatchUi.requestUpdate();
    }
    
    function updateCaloriesMinutesValue(calories as Number) as Void {
        _caloriesLabel.setText("Calories burned:" + calories.toString());
        WatchUi.requestUpdate();
    }

    function updateRespirationMinutesValue(respiration as Number) as Void {
        _respirationLabel.setText("Respiration rates:" + respiration.toString());
        WatchUi.requestUpdate();
    }
}

class CommListener extends Communications.ConnectionListener {

    function initialize() {
        Communications.ConnectionListener.initialize();
    }

    function onComplete() {
        System.println("Transmit Complete");
    }

    function onError() {
        System.println("Transmit Failed");
    }
}
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.System;
import Toybox.Communications;
using Toybox.Sensor;
import Toybox.SensorHistory;

class projView extends WatchUi.View {

    var label;
    var stepsLabel;
    var heartRate = 0;
    var steps = 0;
    var stress = 0;
    var respirationRate = 0;
    var activeMinutesDay = 0;
    var calories = 0;
    var respiration = 0;
    var updateTimer = null;
    var sensorManager;
    var bodyBatery = 0;
    var accelometerX=[];
    var accelometerY=[];
    var accelometerZ=[];
    private var hasBodyBattery as Boolean;

    var _heartRateLabel;
    var _spo2;
    var _stepsLabel;
    var _activeLabel;
    var _caloriesLabel;
    var _respirationLabel;
    var _bodyBattery;

    function initialize() {
        
        View.initialize();
        sensorManager = new SensorManager();
        sensorManager.startAccelerometer();
        hasBodyBattery = Toybox has :SensorHistory && Toybox.SensorHistory has :getBodyBatteryHistory;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _heartRateLabel = findDrawableById("heartRateLabel");
        _stepsLabel = findDrawableById("stepsLabel");
        _activeLabel = findDrawableById("activeLabel");
        _caloriesLabel = findDrawableById("caloriesLabel");
        _respirationLabel = findDrawableById("respirationLabel");
        _spo2 = findDrawableById("spo2");
        _bodyBattery = findDrawableById("bodyBattery");
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

        function getIterator() {
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getOxygenSaturationHistory)) {
            try {
                var ret = Toybox.SensorHistory.getOxygenSaturationHistory({});
                System.println("LAST SAMPLE:" + ret);
                return ret;
            }
            catch( ex ) {
                // Code to catch all execeptions
                return null;
            }
            finally {
                // Code to execute when
            }
        }
        return null;
    }

    function fetchHeartRateData() as Void {
         if (hasBodyBattery) {
            var iterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
            var sample = iterator.next();
            if (sample != null && (sample as SensorSample).data != null) {
                bodyBatery = ((sample as SensorSample).data as Number).toNumber();
                _bodyBattery.setText("Body Battery: " + bodyBatery);
            } else {
                bodyBatery = "--";
            }
        } else {
        }
         var heartRate = null;
         var activity = Activity.getActivityInfo();
        if (activity != null) {
            heartRate = activity.currentHeartRate;
            if(heartRate != null) {
                updateHeartRateValue(heartRate);
            }
        }

        var pulseOxData = null;
        if (Activity.getActivityInfo() has :currentOxygenSaturation) {
        	pulseOxData = Activity.getActivityInfo().currentOxygenSaturation ;
            if (pulseOxData != null) {
                updatePulseOx(pulseOxData);
            }
        }

        var info = ActivityMonitor.getInfo();
        steps = info.steps;
        var distance = info.distance/100;
        calories = info.calories;
        respiration = info.respirationRate;

        updateStepsValue(steps);
        updateCaloriesMinutesValue(calories);
        updateRespirationMinutesValue(respiration);
        accelometerX=sensorManager.accelometerX;
        accelometerY=sensorManager.accelometerY;
        accelometerZ=sensorManager.accelometerZ;
        
        var dataToSend = {
            "heartRate" => heartRate,
            "pulseOx" => pulseOxData,
            "calories"=>calories,
            "respiration"=>respiration,
            "distance"=>distance,
            "steps"=>steps,
            "bodyBatery"=>bodyBatery,
            "accelometerX"=>accelometerX,
            "accelometerY"=>accelometerY,
            "accelometerZ"=>accelometerZ
        };
        System.println("DATA TO SEND" + dataToSend);
        sensorManager.clearAccelometerData();

        var listener = new CommListener();
       // Communications.transmit(dataToSend, null, listener);
    }

    function updateHeartRateValue(heartRate as Number) as Void {
         _heartRateLabel.setText("Heart rate:" + heartRate.toString());
         WatchUi.requestUpdate();
    }

    function updatePulseOx(pulseOx as Number) as Void {
         _spo2.setText("PulseOx:" + pulseOx.toString());
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

class SensorManager {
    const SENSOR_PERIOD_SEC = 4; 
    const SENSOR_FREQ = 10;      
    var accelometerX=[];
    var accelometerY=[];
    var accelometerZ=[];

    function initialize() {
        System.println("SensorManager initialized");
    }
    
    function startAccelerometer() {
        System.println("Starting accelerometer");
        var options = {
            :period => SENSOR_PERIOD_SEC,
            :accelerometer => {
                :enabled => true,
                :sampleRate => SENSOR_FREQ
            }
        };
        
        Sensor.registerSensorDataListener(method(:onAccelData), options);
    }

    function onAccelData(sensorData as Sensor.SensorData) as Void {
        accelometerX.add(sensorData.accelerometerData.x); 
        accelometerY.add(sensorData.accelerometerData.y); 
        accelometerZ.add(sensorData.accelerometerData.z);
    }

    function clearAccelometerData() as Void {
        accelometerX = [];
        accelometerY = [];
        accelometerZ = [];
    }
}

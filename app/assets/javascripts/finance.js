/**
 * This file contains all JavaScript logic pertinent to the finance pages.
 *
 * @author Matt Fornaciari (mattforni@gmail.com)
 */

var LAST_TRADE_URL = '/finance/last_trade';

/**
 * Creates, scopes and binds the FinanceController to the angular module
 * defined in app/assets/javascripts/application.js. It should be noted the
 * '$scopes' declaration is necessary for clarification to the angular injector
 * due to the minfication process.
 */
mattforni.controller('FinanceController', ['$scope',
    function($scope) {
        $scope.accountSize = 0;
        $scope.lastTrade = 0;
        $scope.numShares = 0;
        $scope.positionSize = 0;
        $scope.possibleLoss = 0;
        $scope.risk = 5;
        $scope.stop = 25;
        $scope.stopPrice = 0;
        $scope.symbol = "";

        var a = 0;
        var r = 0;

        /**
         * Formats the stock symbol and then attempts to retrieves a quote for
         * said symbol, updating the lastTrade value on success.
         */
        $scope.last_trade = function() {
            // Makes symbol upper case for compliance
            $scope.symbol = $scope.symbol.toUpperCase();
                $.ajax({
                accepts: 'json',
                data: {
                    symbol: $scope.symbol
                },
                dataType: 'json',
                type: 'GET',
                success: function(data, code, jqXHR) {
                    $scope.lastTrade = data
                    $scope.update(true);
                },
                url: LAST_TRADE_URL
            });

            // Bind the success handler to the ajax request object
            request.done(function(data, code, jqXHR) {
                $scope.lastTrade = data['lastTrade'];
                $scope.update(true);
            });
        } // End $scope.last_trade

        /**
         * Updates all variables associated with position sizing. 
         *
         * @params {boolean} digest Whether or not to digest the scope.
         */
        $scope.update = function(digest) {
            a = $scope.stop == 0 ? 0 : 100.0 / $scope.stop;
            r = $scope.accountSize * ($scope.risk / 100.0);
            $scope.positionSize = a * r;

            // If lastTrade is 0, ignore numShares and stopPrice
            if ($scope.lastTrade == 0) {
                $scope.numShares = 0;
                $scope.stopPrice = 0;
            } else  { // Else calculate the new values
                $scope.numShares = $scope.positionSize / $scope.lastTrade;
                $scope.stopPrice = ((100.0 - $scope.stop)/100.0) * $scope.lastTrade;
            }

            $scope.possibleLoss = ($scope.lastTrade - $scope.stopPrice) * $scope.numShares;
            if (digest) { $scope.$digest(); }
        } // End $scope.update
    } // End anonymous FunctionController function
]);


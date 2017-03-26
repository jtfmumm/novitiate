// define(function(require) {

//     var Console = require("js/screens/Console");

//     var Combat = {
//         attack: function(attacker, defender) {
//             if (attacker.rollToHit(defender.getArmorClass())) {
//                 var damage = attacker.rollToDamage();
//                 defender.loseHP(damage);
//                 Console.msg(attacker.describe() + " hits " + defender.describe() + " for " + damage + " damage!");
//             } else {
//                 Console.msg(attacker.describe() + " misses!");
//             }
//         }
//     };

//     return Combat;
// });

        // rollToHit: function(targetArmorClass) {
        //     return Rand.roll(20) > targetArmorClass;
        // },
        // rollToDamage: function() {
        //     return this.attackDice.roll() + this.hitBonus;
        // },
        // loseHP: function(damage) {
        //     this.hp -= damage;
        //     if (this.isDead()) this.fall();
        // },

// define(function(require) {
    
//     var bonuses = {
//         3: -3,
//         5: -2,
//         8: -1,
//         12: 0,
//         15: 1,
//         17: 2,
//         18: 3
//     };

//     return {
//         bonuses: bonuses
//     }
// });
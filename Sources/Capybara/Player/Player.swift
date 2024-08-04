import Foundation

struct Player: Identifiable {
    let id: String = UUID().uuidString
    let firstName: String
    let lastName: String
    // MARK: - PHYSICAL STATS
    let height: Int // in inches
    var weight: Int // in lbs
    var leanMusclePercentage: Int // 50 to 95
    var endurance: Int
    // MARK: - ATHLETIC STATS
    var straightLineSpeed: Int // 1 to 100
    var vertical: Int // 1 to 100
    var lateralQuickness: Int // 1 to 100
    var strength: Int // 1 to 100
    // MARK: - SCORING OFFENSE
    var threePointShooting: Int // 1 to 100
    var midRangeShooting: Int // 1 to 100
    var finishingAroundTheBasket: Int // 1 to 100
    var handle: Int // 1 to 100
    var speedOffDribble: Int // 1 to 100
    var foulBaiting: Int // 1 to 100
    // MARK: - SUPPORTING OFFENSE
    /// A player's `screen` attribute corresponds to an offensive player's `lateralQuickness` attribute as well as their `strength` attribute
    ///
    /// When a defensive player attempts a screen on an offensive player, we resolve to 1 of 4 outcomes:
    ///  - We can resolve to a charge if the offensive player has possession of the ball, high `strength`, low `awareness`, and low `lateralQuickness`
    ///  - We can resolve to a blocking foul if the offensive player has possession of the ball, high `lateralQuickness` and high `foulBaiting`
    ///  - We can resolve to a moving screen if the defensive player has  low `screen `and  low `awareness`
    ///  - In the majority of cases, we resolve to a successful screen, and move the next action to the screened defender to decide to go over or under the screen, and whether to switch
    var screen: Int // 1 to 100
    /// A player's `passing` attribute refers to how well they can find the open man
    var passing: Int // 1 to 100
    // MARK: - POA DEFENSE
    ///A player's `steal` attribute correspond to an offensive player's `handle` attribute,
    ///and tangentially to both the offensive player's `speedOffDribble` attribute and their `foulBaiting` attribute
    ///
    ///When a defensive player attempts a steal, this triggers a few checks:
    ///
    /// If the defensive player is in front of the offensive player, we continue. If not, the steal was unsuccessful and the defensive player is incapacitated for several ticks
    ///
    /// If the offensive player is making a move towards the basket, we continue. If not, the steal was unsuccessful and the defensive player is incapacitated for several ticks
    ///
    /// Given all the above checks passed, we simulate the steal with 3 potential outcomes
    /// - Reach-in foul - hits based on some randomness + the offensive player's `foulBaiting` attribute + the defensive player's `awareness` attribute
    /// - Successful steal - hits based on some randomness
    /// - Unsuccessful steal, defensive player incapacitated for several ticks - hits based on some randomness
    var steal: Int // 1 to 100
    /// A player's `block` attribute corresponds to an offensive player's relevant shooting attribute (depending on where they are on the court)
    /// and tangentially to the offensive player's `foulBaiting` attribute
    ///
    /// When a defensive player attempts a block, this triggers a few checks:
    ///
    /// - If the defensive player is in front of the offensive player, we continue. If not, the steal was unsuccessful and the defensive player is incapacitated for several ticks
    /// - If the offensive player is in the act of shooting, we resolve the outcome of the play:
    ///     -  We use the defensive player's height and vertical as well as their distance to the offensive player to "contest" the shot
    ///     - Depending on the offensive player's `foulBaiting` attribute, the defensive player's `awareness` attribute and some randomness, we apply some additional difficulty to the shot and call a foul
    var block: Int // 1 to 100
    /// A player's `awareness` attribute indicates how likely they are to make the right read on the court. This attribute affects:
    /// - Going over/under screens
    /// - Knowing when to switch on screens
    /// - Attempting a steal at the most opportune time
    /// - Attempting a block at the most opportune time
    var awareness: Int // 1 to 100
}

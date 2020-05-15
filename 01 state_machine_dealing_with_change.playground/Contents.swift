import Cocoa

struct Transition {
    var targetState:    State
    var effect:         Effect? = nil
    
    typealias Effect = ( System ) -> ()
}



protocol Events
{
    mutating func arm( _: System )                          -> Transition?
    mutating func disarm( usingCode: String, _: System )    -> Transition?
    mutating func breach( _: System )                       -> Transition?
    mutating func panic( _: System )                        -> Transition?
    mutating func reset( usingCode: String, _: System )     -> Transition?
}



extension Events
{
    mutating func arm( _: System )                          -> Transition? { return nil }
    mutating func disarm( usingCode: String, _: System )    -> Transition? { return nil }
    mutating func breach( _: System )                       -> Transition? { return nil }
    mutating func panic( _: System )                        -> Transition? { return nil }
    mutating func reset( usingCode: String, _: System )     -> Transition? { return nil }
}



protocol Activities
{
    func enter( _: System )
    func exit( _: System )
}



extension Activities {
    func enter( _: System ) {}
    func exit( _: System )  {}
}



typealias State = Events & Activities



class System
{
    init( code: String )
    {
        self.code = code
        
        state = DisarmedState()
    }
    
    func arm()
    {
        process( transition: state.arm( self ) )
    }
    
    func disarm( usingCode code: String )
    {
        process( transition: state.disarm( usingCode: code, self ) )
    }
    
    func breach()
    {
        process( transition: state.breach( self ) )
    }
    
    func panic()
    {
        process( transition: state.panic( self ) )
    }
    
    func reset( usingCode code: String )
    {
        process(transition: state.reset( usingCode: code, self ) )
    }
    
    func isValid( code: String ) -> Bool
    {
        let isValid = code == self.code
        
        print( isValid ? "Code accepted" : "Invalid code" )
        
        return isValid
    }
    
    private func process( transition: Transition? )
    {
        guard let transition = transition else { return }
        
        state.exit( self )
        
        transition.effect?( self )
        
        state = transition.targetState
        
        state.enter( self )
    }
    
    private var state: State
    private let code: String
}



struct DisarmedState: State
{
    func enter( _: System )
    {
        print( "System disarmed" )
    }
    
    func arm( _ system: System ) -> Transition?
    {
        return Transition( targetState: ArmedState() )
    }
    
    func panic(_ system: System) -> Transition?
    {
        return Transition( targetState: AlarmState() )
    }
}



struct ArmedState: State
{
    private var disarmAttempts      = 0
    private let maxDisarmAttempts   = 3
    
    func enter( _: System )
    {
        print( "System armed" )
    }

    mutating func disarm( usingCode code: String, _ system: System ) -> Transition?
    {
        disarmAttempts += 1
        
        if system.isValid( code: code )
        {
            return Transition( targetState: DisarmedState() )
        }
        else if disarmAttempts > maxDisarmAttempts
        {
            return Transition( targetState: AlarmState() ) { system in
                    print( "Administrator informed" )
            }
        }
        else
        {
            return nil
        }
    }
    
    func breach( _ system: System ) -> Transition?
    {
        return Transition( targetState: AlarmState() )
    }
    
    func panic( _ system: System ) -> Transition?
    {
        return Transition( targetState: AlarmState() )
    }
}



struct AlarmState: State
{
    func enter(_: System)
    {
        print( "Alarm sounded" )
    }
    
    func exit( _: System )
    {
        print( "Alarm stopped" )
    }
    
    func reset( usingCode code: String, _ system: System ) -> Transition?
    {
        guard system.isValid(code: code) else { return nil }
        
        return Transition( targetState: DisarmedState() )
    }
}



let system = System( code: "1234" )

system.breach()
system.panic()

system.arm()                        // System armed
system.breach()                     // Alarm sounded
system.reset( usingCode: "1234" )   // Code accepted
                                    // Alarm stopped
                                    // System disarmed

system.arm()                        // System armed
system.disarm( usingCode: "0000" )  // Invalid code
system.disarm( usingCode: "1234" )  // Code accepted
                                    // System disarmed

print( "------" )

let system2 = System(code: "1234")

system2.panic()                     // Alarm sounded

print( "------" )

let system3 = System(code: "1234")

system3.arm()                       // System armed
system3.disarm(usingCode: "0000")   // Invalid code
system3.disarm(usingCode: "1111")   // Invalid code
system3.disarm(usingCode: "2222")   // Invalid code
system3.disarm(usingCode: "3333")   // Invalid code
                                    // Administrator informed
                                    // Alarm sounded




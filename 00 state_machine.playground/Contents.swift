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
}



struct ArmedState: State
{
    func enter( _: System )
    {
        print( "System armed" )
    }

    func disarm( usingCode code: String, _ system: System ) -> Transition?
    {
        guard system.isValid( code: code ) else { return nil }
        
        return Transition( targetState: DisarmedState() )
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






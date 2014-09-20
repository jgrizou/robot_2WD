clear all
init

robot = TwoWheelRobot();
robot.set_state(0.25, 0, pi/2);
robot.set_wheelDrive(40, 50);
robot.set_nominal_drive(30);
robot.set_curve(0.1);
robot.groundSensorShift = [robot.robotRadius, 0];
robot.groundSensorSpan = 1;

robot.followGain = 100;

s1 = Segment.circle([0.5, 0.75], 0.5, -pi/2, pi);
s2 = Segment.circle([0.5,0], 0.25, pi/2, 3*pi/2);
s3 = Segment.circle([0.5,-0.75], 0.5, pi, 5*pi/2);
s4 = Segment.ellipse([0, 0], 0.25, 0.75, 0, pi/2, 3*pi/2);
trajToFollow = Trajectory(s1, s2, s3, s4);

run = true;
updateTime = 0.1;

posRobot = [];
while run
    robot.follow(trajToFollow)
    robot.update_state(updateTime)
    
    trajRobot = robot.get_ground_sensor_trajectory();
    [x0,y0] = Trajectory.intersections(trajToFollow, trajRobot);
    
    posRobot = [posRobot; [robot.x, robot.y]];
    
    clf
    robot.plot()
    trajToFollow.plot()
    trajRobot.plot(100, 'g')
    plot(x0, y0, 'r*')
    plot(posRobot(:,1), posRobot(:,2), 'r')
    
    xlim([-2,2])
    ylim([-2,2])
    drawnow
    pause(updateTime)
    
    if robot.x > 2 || robot.x < -2 || robot.y > 2 || robot.y < -2
        run = false;
    end
end






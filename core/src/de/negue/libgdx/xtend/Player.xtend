package de.negue.libgdx.xtend

import com.badlogic.gdx.physics.box2d.World
import com.badlogic.gdx.physics.box2d.BodyDef
import com.badlogic.gdx.physics.box2d.BodyDef$BodyType
import com.badlogic.gdx.physics.box2d.Body
import com.badlogic.gdx.physics.box2d.PolygonShape
import com.badlogic.gdx.physics.box2d.CircleShape
import com.badlogic.gdx.math.Vector2

import static extension java.util.Collections.*
import com.badlogic.gdx.physics.box2d.Fixture

class Player {
  
  World world;
  var doJump = false
  val MAX_VELOCITY = 7f
  
  public Body box
  
  public Fixture physicsFixture
  
  public Fixture sensorFixture

  public Long lastGroundTime = 0l

  def velocity(){ box.getLinearVelocity}
  def position(){ box.getPosition }

  new(World _world){
    world = _world;
    
    /* Some Advanced Example of Xtend */
    box =  {
      val bodyDef = new BodyDef()
      bodyDef.type = BodyType::DynamicBody
      world.createBody(bodyDef)  
    } => [
      setBullet(true)

      setTransform(10.0f, 4.0f, 0)
      setFixedRotation(true)
    ]
    
    sensorFixture = {
      val circle = new CircleShape => [
        setRadius(0.45f)
        setPosition(new Vector2(0, -1.4f))
      ]
    
      val fixture = box.createFixture(circle, 0)
      circle.dispose
      fixture
    }
    
    physicsFixture  = {
      val poly = new PolygonShape
      poly.setAsBox(0.45f, 1.4f)
      val fixture = box.createFixture(poly, 1)
      poly.dispose
      fixture
    }
  }
  
  def limitVelocity() {
    velocity.x = Math::signum(velocity.x) * MAX_VELOCITY
    box.setLinearVelocity(velocity.x, velocity.y)
  }

  def jump() {
    box.setLinearVelocity(velocity.x, 0)
    
    box.setTransform(position.x, position.y + 0.01f, 0)
    box.applyLinearImpulse(0, 30, position.x, position.y)
  }

  def moveLeft(){ 
    if (velocity.x > -MAX_VELOCITY) {
      box.applyLinearImpulse(-2f, 0, position.x, position.y)
    }
  }

  def moveRight(){ 
    if (velocity.x < MAX_VELOCITY) {
      box.applyLinearImpulse(2f, 0, position.x, position.y)
    }
  }

  def isGrounded(){
    world.contactList.exists[
      /* it = currentItem in loop of contactList, also "it" is optional */
      if(it.touching && (
        it.fixtureA == sensorFixture ||
        it.fixtureB == sensorFixture)){
          val position = box.position
          val manifold = it.worldManifold
          
          manifold.points.exists[point | /* "point |" can be removed, but then "it" must be used */
            point.y < position.y - 1.5f
          ]
        }
      else
        false /* return is optional */ 
    ]
  }
}
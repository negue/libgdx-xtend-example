package de.negue.libgdx.xtend

import com.badlogic.gdx.InputAdapter
import com.badlogic.gdx.Input$Keys
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.physics.box2d.BodyDef$BodyType
import com.badlogic.gdx.Screen
import com.badlogic.gdx.physics.box2d.World
import com.badlogic.gdx.math.Vector2
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.physics.box2d.Box2DDebugRenderer
import com.badlogic.gdx.math.Matrix4
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.GL10
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.math.Vector3
import com.badlogic.gdx.physics.box2d.BodyDef$BodyType
import com.badlogic.gdx.physics.box2d.BodyDef
import com.badlogic.gdx.physics.box2d.EdgeShape
import com.badlogic.gdx.physics.box2d.PolygonShape
import com.badlogic.gdx.math.MathUtils

class XtendScreen extends InputAdapter implements Screen {
  XtendGame game;  
  
  new(XtendGame _game){
    game = _game;
    
    Gdx::input.setInputProcessor(this)
    
    createGround()
    for(i : 0..49) {
      val box = createBox(BodyType::DynamicBody, MathUtils::random(), MathUtils::random(), 3)
      box.setTransform(MathUtils::random() * 10f - MathUtils::random() * 10f, MathUtils::random() * 10 + 6, MathUtils::random() * 2 * MathUtils::PI)
    }
  }


  val world = new World(new Vector2(0, -20), true)
  val player = new Player(world)
  val cam = new OrthographicCamera(28, 20)
  val renderer = new Box2DDebugRenderer()
  val matrix = new Matrix4()
  val font = new BitmapFont() => [setColor(Color::WHITE)]
  
  val batch = new SpriteBatch()
  val point = new Vector3()
  
  // VARS
  var shouldJump = false
  var rightPressed = false
  var leftPressed = false
  var grounded = false
  var stillTime = 0f

  override render(float delta) {
    Gdx::gl.glClear(GL10::GL_COLOR_BUFFER_BIT)
    cam.position.set(player.position.x, player.position.y, 0)
    cam.update
    cam.apply(Gdx::gl10)
    matrix.set(cam.combined)
    renderer.render(world, matrix)
    cam.project(point.set(player.position.x, player.position.y, 0))
    batch.begin()
    font.drawMultiLine(batch, 
      "friction: " + player.physicsFixture.getFriction() + "\ngrounded: " + grounded,
      point.x + 20, point.y)
    batch.end()
    update(delta)
  }

  def update(float delta) {
    val now = System::nanoTime
    grounded = {
      val g = player.isGrounded
      if (g) player.lastGroundTime = now
      g || now - player.lastGroundTime < 100000000
    }

    player.limitVelocity()

    if(!leftPressed && !rightPressed) {
      stillTime = stillTime + Gdx::graphics.getDeltaTime()
      player.box.setLinearVelocity(player.velocity.x * 0.9f, player.velocity.y)
    }

    if (grounded) {
      if(leftPressed || rightPressed) {
        player.physicsFixture.setFriction(0.2f)
        player.sensorFixture.setFriction(0.2f)
        stillTime = 0
      } else if(stillTime > 0.2) {
        player.physicsFixture.setFriction(100f)
        player.sensorFixture.setFriction(100f)
      }
    } else {
      player.physicsFixture.setFriction(0f)
      player.sensorFixture.setFriction(0f)
    }

    if (leftPressed) player.moveLeft
    if (rightPressed) player.moveRight

    if (shouldJump) {
      shouldJump = false
      if (grounded) {
        player.jump()
      }
    }
    world.step(Gdx::graphics.getDeltaTime(), 4, 4)
    player.box.setAwake(true)

  }

  override keyDown(int keycode) {
    if (keycode == Keys::W) shouldJump = true
    if (keycode == Keys::A) leftPressed = true
    if (keycode == Keys::D) rightPressed = true
    false
  }

  override keyUp(int keycode) {
    if (keycode == Keys::W) shouldJump = false
    if (keycode == Keys::A) leftPressed = false
    if (keycode == Keys::D) rightPressed = false
    false
  }

  def createGround(){
    var y1 = 1f
    var y2 = y1

    for (i : 0..49) {
      val ground = createEdge(BodyType::StaticBody, -50 + i * 2, y1, -50 + i * 2 + 2, y2, 0)
      y1 = y2
      y2 = 1 //(float)Math.random() + 1;
    }
  }

  def createEdge(BodyType t, float x1, float y1, float x2, float y2, float density) {
    val bDef = new BodyDef => [type = t]
    return world.createBody(bDef) => [
      val poly = new EdgeShape() => [
        set(new Vector2(0, 0), new Vector2(x2 - x1, y2 - y1))
      ]
      
      createFixture(poly, density)
      setTransform(x1, y1, 0)
      
      poly.dispose()
    ]
  }

  def createBox(BodyType t, float width, float height, float density) {
    val bDef = new BodyDef() => [type = t]
    
    return world.createBody(bDef) => [
      val poly = new PolygonShape() => [setAsBox(width, height)]

      createFixture(poly, density)
    ]
  } 

  override dispose() {
 
 }
  
  override hide() {

  }
  
  override pause() {

  }
  
  override resize(int arg0, int arg1) {

  }
  
  override resume() {

  }
  
  override show() {

  }
  
}
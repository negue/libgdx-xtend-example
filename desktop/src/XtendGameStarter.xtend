import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration
import de.negue.libgdx.xtend.XtendGame

class XtendGameStarter {
  def static void main(String[] arg) {
    val cfg = new LwjglApplicationConfiguration()
    cfg.title = "puzzleplatform"
    cfg.useGL20 = false
    cfg.width = 800
    cfg.height = 480
    cfg.resizable = false
    
    new LwjglApplication(new XtendGame(), cfg)
  }
}
/**
 * generated by iCampus (JooMDD team) 2.9.1
 */
package de.thm.icampus.joomdd.ejsl.web;

import com.google.inject.Provider;
import de.thm.icampus.joomdd.ejsl.web.AbstractEJSLWebModule;
import java.util.concurrent.ExecutorService;
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor;

/**
 * Use this class to register additional components to be used within the web application.
 */
@FinalFieldsConstructor
@SuppressWarnings("all")
public class EJSLWebModule extends AbstractEJSLWebModule {
  public EJSLWebModule(final Provider<ExecutorService> executorServiceProvider) {
    super(executorServiceProvider);
  }
}

package classes;

import com.intellij.ide.util.projectWizard.ModuleWizardStep;
import com.intellij.openapi.util.IconLoader;
import com.intellij.ui.components.JBScrollPane;
import com.intellij.util.PathUtil;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;

/**
 * Created by Max on 28.01.2016.
 */
public class eJSLWizardStep extends ModuleWizardStep {

    private static String option = "";
    private static boolean wizardstatus = false;

    public static void setwizardstatus(boolean status) {wizardstatus = status;}
    public static String getOption(){
        return option;
    }
    public static void setOption(String newoption) {option = newoption;}
    public static boolean getwizardactive() {return  wizardstatus;}

    public String getPreviewFromFile(String filename){

        StringBuilder preview = new StringBuilder();

        try{
            FileReader fr = new FileReader(PathUtil.getJarPathForClass(getClass()) + "/templates/"+filename);
            BufferedReader br = new BufferedReader(fr);

            String buffer = "";
            String text = "";
            int maxLines = 20;
            int lines = 0;

            while ((buffer = br.readLine()) != null) {

                text += buffer + "\n";
                lines+=1;
                if(lines>maxLines){
                    break;
                }
            }
            preview.append(text);
            br.close();
            fr.close();
        }  catch (Exception e1) {
            e1.printStackTrace();
        }
        return preview.toString();
    }

    @Override
    public JComponent getComponent() {
        TemplateList tempList = new TemplateList();

        try {
            tempList = TemplateXMLLoader.loadTemplates(PathUtil.getJarPathForClass(getClass()) + "/templates/TemplateList.xml", PathUtil.getJarPathForClass(getClass()) + "/templates/TemplateList.xsd");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        Object[] t = tempList.getTemplates();
        Template[] temps = new Template[t.length];

        for (int i = 0; i < t.length; i++){
            temps[i] = (Template) t[i];
        }

        JPanel panel = new JPanel(new BorderLayout());
        JPanel selectPanel = new JPanel(new BorderLayout());
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new BoxLayout(buttonPanel, BoxLayout.PAGE_AXIS));
        JPanel secondPanel = new JPanel(new BorderLayout());
        JPanel descriptionPanel = new JPanel(new BorderLayout());
        JPanel previewPanel = new JPanel((new BorderLayout()));

        JLabel joomddlogo = new JLabel(IconLoader.getIcon("/resources/icons/Logo_b_small.png"));
        JLabel selectLabel = new JLabel("Load example:");
        JLabel descriptionLabel = new JLabel("<html><br>Description:<html>");
        JLabel descriptionText = new JLabel();
        JLabel previewLabel = new JLabel("Preview:");
        JTextArea previewText  = new JTextArea("");
        previewText.setEnabled(false);

        JBScrollPane selectScroll = new JBScrollPane(buttonPanel);
        selectScroll.setPreferredSize(new Dimension(150,250));
        JBScrollPane previewScroll = new JBScrollPane(previewLabel);
        previewScroll.setPreferredSize(new Dimension(400,250));

        panel.add(joomddlogo, BorderLayout.NORTH);
        panel.add(selectPanel, BorderLayout.WEST);
        panel.add(secondPanel, BorderLayout.CENTER);

        JRadioButton[] radio = new JRadioButton[temps.length];

        selectPanel.add(selectLabel, BorderLayout.NORTH);
        selectPanel.add(selectScroll, BorderLayout.CENTER);

        secondPanel.add(descriptionPanel,BorderLayout.NORTH);
        secondPanel.add(previewPanel,BorderLayout.CENTER);

        descriptionPanel.add(descriptionLabel, BorderLayout.NORTH);
        descriptionPanel.add(previewScroll, BorderLayout.CENTER);
        descriptionPanel.add(descriptionText, BorderLayout.CENTER);

        previewPanel.add(previewLabel, BorderLayout.NORTH);
        previewPanel.add(previewText,BorderLayout.CENTER);

        selectLabel.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));
        selectScroll.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));
        previewLabel.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));
        previewScroll.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));


        for (int i = 0; i < radio.length; i++){
            radio[i] = new JRadioButton(temps[i].getName());
            buttonPanel.add(radio[i]);

            final int j = i;
            radio[i].addActionListener(new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent e) {
                    if(radio[j].isSelected()){
                        setOption(temps[j].getSrc().toString());

                        for(int k = 0; k < radio.length; k++){
                            if(k != j) radio[k].setSelected(false);
                        }
                        if(temps[j].getDescription() == null){
                            descriptionText.setText("This template has no description.");
                        }else {
                            descriptionText.setText(temps[j].getDescription().toString());
                        }
                        previewText.setText(getPreviewFromFile(temps[j].getSrc().toString()));
                    }
                }
            });
        }
        radio[0].setSelected(true);
        setOption(temps[0].getSrc().toString());
        previewText.setText(getPreviewFromFile(temps[0].getSrc().toString()));
        if(temps[0].getDescription() == null){
            descriptionText.setText("This template has no description.");
        }else {
            descriptionText.setText(temps[0].getDescription().toString());
        }
        return panel ;
    }

    @Override
    public void updateDataModel() {
        wizardstatus = true ;
    }
}
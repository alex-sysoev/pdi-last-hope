defmodule PdiLastHope do
  @moduledoc """
  Simple Elixir scraper for appointment reservation. Because of huge amount of
  imigrants it is almost imposible to manualy reserve the appointment in chilean PDI.
  This version does not contain tests because it is actually one big test for external
  site :)
  """
  use Hound.Helpers

  @states %{
    no_service: "Sin Atención",
    not_available: "No Disponible",
    available: "DISPONIBLE"
  }

  @issues %{
    "Ampliación de solicitud de PERMANENCIA DEFINITIVA en trámite" => "17",
    "Ampliación de Solicitud de Visa en trámite" => "7",
    "Ampliación de Turismo" => "1",
    "Autorización de trabajo como Turista" => "3",
    "Autorización de trabajo con visa en trámite" => "15",
    "Entrega de Certificado de Permanencia Definitiva" => "19",
    "Entrega de certificados de devolución de dinero" => "14",
    "Estampados de visa en pasaportes" => "20",
    "(PDI) Certificado de viajes y Registro de visa para postular a la Permanencia Definitiva" => "31",
    "(PDI) Certificado de vigencia Permanencia Definitiva" => "33",
    "(PDI) Duplicado de Registro de visa" => "35",
    "(PDI) Registro de Visa" => "32",
    "(PDI) Registro Permanencia Definitiva" => "26",
    "Prórroga de Turismo" => "2",
    "***REGULARIZACIÓN MIGRATORIA 2018*** (Estampado)" => "22",
    "Reimpresiones de Ordenes de Pago" => "5",
    "Sanción Empleador Paso 1: Cálculo del monto de la multa para solicitar vale vista en banco" => "10",
    "Sanción Empleador Paso 2: Entrega de vale vista y emisión de resolución de sanción pagada" => "12",
    "Sanción Extranjero Paso 1: Cálculo del monto de la multa para solicitar vale vista en banco" => "9",
    "Sanción Extranjero Paso 2: Entrega de vale vista y emisión de resolución de sanción pagada" => "11",
    "Títulos de residencia" => "13",
    "*TRAMITADORES* (Apoderado en poder de otra persona)" => "23",
    "Traspaso de visa" => "16"
  }

  def exec do
    Hound.start_session()

    Hound.Helpers.Navigation.navigate_to("https://reservahora.extranjeria.gob.cl/inicio.action")

    login()

    :timer.sleep(2000)

    button = Hound.Helpers.Page.find_element(:id, "btnReservarHora")
    Hound.Helpers.Element.click(button)

    select_procedure("13", "130", "#{issue()}")
    background()
    requirements()
    user_data()

    case calendar() do
      :reserved ->
        Hound.end_session()
        IO.puts("An appointment was reserved and sent to your email.")
        :done
      :missed ->
        Hound.end_session()
        IO.puts("Nothing is available at this time. \n\n")
        :restart
    end
  end

  defp login() do
    :timer.sleep(2000)

    form = Hound.Helpers.Page.find_element(:name, "j_security_check")
    email_input = Hound.Helpers.Page.find_element(:name, "j_username")
    password_input = Hound.Helpers.Page.find_element(:name, "j_password")
    Hound.Helpers.Element.fill_field(email_input, email())
    Hound.Helpers.Element.fill_field(password_input, password())
    Hound.Helpers.Element.submit_element(form)    
  end

  defp select_procedure(region, county, procedure) do
    resolve_modal("Aceptar")
    
    :css
    |> Hound.Helpers.Page.find_element("#cmbRegionesST option[value='#{region}']")
    |> Hound.Helpers.Element.click()

    :css
    |> Hound.Helpers.Page.find_element("#cmbComunasST option[value='#{county}']")
    |> Hound.Helpers.Element.click()

    :css
    |> Hound.Helpers.Page.find_element("#cmbTramitesDisponiblesST option[value='#{procedure}']")
    |> Hound.Helpers.Element.click()
    
    :id
    |> Hound.Helpers.Page.find_element("btnSiguienteST")
    |> Hound.Helpers.Element.click()
  end

  defp background do
    :timer.sleep(2000)

    :id
    |> Hound.Helpers.Page.find_element("btnSiguienteAG")
    |> Hound.Helpers.Element.click()
  end

  defp requirements do
    :timer.sleep(2000)

    :name
    |> Hound.Helpers.Page.find_element("cumpleRequisitos")
    |> Hound.Helpers.Element.click()

    :id
    |> Hound.Helpers.Page.find_element("btnSiguienteRB")
    |> Hound.Helpers.Element.click()
  end

  defp user_data do
    resolve_modal("No")
    resolve_modal("Aceptar")
  end

  defp calendar do
    :timer.sleep(2000)

    titles =
      :class
      |> Hound.Helpers.Page.find_all_elements("fc-event-title")
      |> Enum.map(& Hound.Helpers.Element.inner_text(&1))
      |> Enum.uniq()
      |> Enum.map(&String.trim/1)

    if Enum.member?(titles, @states.available) do
      IO.puts("BAKAN!")
      reserve()
      :reserved
    else
      next = Hound.Helpers.Page.find_element(:id, "btnNext")
      
      if Hound.Helpers.Element.element_enabled?(next) do
        IO.puts("Checking the next week availibility...")
        Hound.Helpers.Element.click(next)
        calendar()
      else
        :missed 
      end
    end
  end

  defp reserve do
    cells =
      :class
      |> Hound.Helpers.Page.find_all_elements("fc-event")
      |> Enum.filter(fn(cell) ->
        cell
        |> Hound.Helpers.Element.inner_text()
        |> String.contains?(@states.available)
      end)

    cells
    |> Enum.at(0)
    |> Hound.Helpers.Element.click()

    resolve_modal("Confirmar")
  end

  defp resolve_modal(btn_text) do
    :timer.sleep(2000)

    :class  
    |> Hound.Helpers.Page.find_all_elements("ui-dialog")
    |> Enum.filter(& Hound.Helpers.Element.visible_text(&1) != "")
    |> Enum.at(0)
    |> Hound.Helpers.Page.find_all_within_element(:tag, "button")
    |> Enum.filter(fn(btn) ->
      text =
        btn
        |> Hound.Helpers.Element.inner_text()
        |> String.trim()
      
      text == btn_text
    end)
    |> Enum.at(0)
    |> Hound.Helpers.Element.click()    
  end

  defp email, do: Application.get_env(:pdi_last_hope, :email)
  defp password, do: Application.get_env(:pdi_last_hope, :password)
  defp issue, do: Application.get_env(:pdi_last_hope, :issue)

end

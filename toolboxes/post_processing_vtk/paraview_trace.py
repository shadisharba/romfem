# trace generated using paraview version 5.6.0
#
# To ensure correct image size when batch processing, please search 
# for and uncomment the line `# renderView*.ViewSize = [*,*]`

#### import the simple module from the paraview
from paraview.simple import *
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

# create a new 'XML Unstructured Grid Reader'
output_ = XMLUnstructuredGridReader(FileName=['/home/alameddin/src/romfem/output/vtk/output_1.vtu', '/home/alameddin/src/romfem/output/vtk/output_2.vtu', '/home/alameddin/src/romfem/output/vtk/output_3.vtu', '/home/alameddin/src/romfem/output/vtk/output_4.vtu', '/home/alameddin/src/romfem/output/vtk/output_5.vtu', '/home/alameddin/src/romfem/output/vtk/output_6.vtu', '/home/alameddin/src/romfem/output/vtk/output_7.vtu', '/home/alameddin/src/romfem/output/vtk/output_8.vtu', '/home/alameddin/src/romfem/output/vtk/output_9.vtu', '/home/alameddin/src/romfem/output/vtk/output_10.vtu', '/home/alameddin/src/romfem/output/vtk/output_11.vtu', '/home/alameddin/src/romfem/output/vtk/output_12.vtu', '/home/alameddin/src/romfem/output/vtk/output_13.vtu', '/home/alameddin/src/romfem/output/vtk/output_14.vtu', '/home/alameddin/src/romfem/output/vtk/output_15.vtu', '/home/alameddin/src/romfem/output/vtk/output_16.vtu', '/home/alameddin/src/romfem/output/vtk/output_17.vtu', '/home/alameddin/src/romfem/output/vtk/output_18.vtu', '/home/alameddin/src/romfem/output/vtk/output_19.vtu', '/home/alameddin/src/romfem/output/vtk/output_20.vtu', '/home/alameddin/src/romfem/output/vtk/output_21.vtu', '/home/alameddin/src/romfem/output/vtk/output_22.vtu', '/home/alameddin/src/romfem/output/vtk/output_23.vtu', '/home/alameddin/src/romfem/output/vtk/output_24.vtu', '/home/alameddin/src/romfem/output/vtk/output_25.vtu', '/home/alameddin/src/romfem/output/vtk/output_26.vtu', '/home/alameddin/src/romfem/output/vtk/output_27.vtu', '/home/alameddin/src/romfem/output/vtk/output_28.vtu', '/home/alameddin/src/romfem/output/vtk/output_29.vtu', '/home/alameddin/src/romfem/output/vtk/output_30.vtu', '/home/alameddin/src/romfem/output/vtk/output_31.vtu', '/home/alameddin/src/romfem/output/vtk/output_32.vtu', '/home/alameddin/src/romfem/output/vtk/output_33.vtu', '/home/alameddin/src/romfem/output/vtk/output_34.vtu', '/home/alameddin/src/romfem/output/vtk/output_35.vtu', '/home/alameddin/src/romfem/output/vtk/output_36.vtu', '/home/alameddin/src/romfem/output/vtk/output_37.vtu', '/home/alameddin/src/romfem/output/vtk/output_38.vtu', '/home/alameddin/src/romfem/output/vtk/output_39.vtu', '/home/alameddin/src/romfem/output/vtk/output_40.vtu', '/home/alameddin/src/romfem/output/vtk/output_41.vtu'])
output_.PointArrayStatus = ['stress', 'strain', 'internal_damage', 'strain_spatial_modes', 'equivalent_stress', 'equivalent_strain', 'equivalent_strain_spatial_modes']

# get animation scene
animationScene1 = GetAnimationScene()

# update animation scene based on data timesteps
animationScene1.UpdateAnimationUsingDataTimeSteps()

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')
# uncomment following to set a specific view size
# renderView1.ViewSize = [624, 745]

# show data in view
output_Display = Show(output_, renderView1)

# trace defaults for the display properties.
output_Display.Representation = 'Surface'
output_Display.ColorArrayName = [None, '']
output_Display.OSPRayScaleArray = 'equivalent_strain'
output_Display.OSPRayScaleFunction = 'PiecewiseFunction'
output_Display.SelectOrientationVectors = 'None'
output_Display.ScaleFactor = 2.0
output_Display.SelectScaleArray = 'None'
output_Display.GlyphType = 'Arrow'
output_Display.GlyphTableIndexArray = 'None'
output_Display.GaussianRadius = 0.1
output_Display.SetScaleArray = ['POINTS', 'equivalent_strain']
output_Display.ScaleTransferFunction = 'PiecewiseFunction'
output_Display.OpacityArray = ['POINTS', 'equivalent_strain']
output_Display.OpacityTransferFunction = 'PiecewiseFunction'
output_Display.DataAxesGrid = 'GridAxesRepresentation'
output_Display.SelectionCellLabelFontFile = ''
output_Display.SelectionPointLabelFontFile = ''
output_Display.PolarAxes = 'PolarAxesRepresentation'
output_Display.ScalarOpacityUnitDistance = 3.0714860080511293

# init the 'GridAxesRepresentation' selected for 'DataAxesGrid'
output_Display.DataAxesGrid.XTitleFontFile = ''
output_Display.DataAxesGrid.YTitleFontFile = ''
output_Display.DataAxesGrid.ZTitleFontFile = ''
output_Display.DataAxesGrid.XLabelFontFile = ''
output_Display.DataAxesGrid.YLabelFontFile = ''
output_Display.DataAxesGrid.ZLabelFontFile = ''

# init the 'PolarAxesRepresentation' selected for 'PolarAxes'
output_Display.PolarAxes.PolarAxisTitleFontFile = ''
output_Display.PolarAxes.PolarAxisLabelFontFile = ''
output_Display.PolarAxes.LastRadialAxisTextFontFile = ''
output_Display.PolarAxes.SecondaryRadialAxesTextFontFile = ''

# reset view to fit data
renderView1.ResetCamera()

# update the view to ensure updated data information
renderView1.Update()

# set scalar coloring
ColorBy(output_Display, ('POINTS', 'internal_damage'))

# rescale color and/or opacity maps used to include current data range
output_Display.RescaleTransferFunctionToDataRange(True, False)

# show color bar/color legend
output_Display.SetScalarBarVisibility(renderView1, True)

# get color transfer function/color map for 'internal_damage'
internal_damageLUT = GetColorTransferFunction('internal_damage')

# get opacity transfer function/opacity map for 'internal_damage'
internal_damagePWF = GetOpacityTransferFunction('internal_damage')

# change representation type
output_Display.SetRepresentationType('Surface With Edges')